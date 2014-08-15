module engine.mesh;

struct Mesh {
	import glwtf.window;
	import gl3n.linalg;
	import gl3n.math;
	import dgl;
	import glamour.texture;
	import engine.model_loader;
	import std.path : buildPath, dirName;
	import std.file : thisExePath;
	import glad.gl.all;

	this(string modelName, string textureName) {
		this.modelName = modelName;
		this.textureName = textureName;
        this.workDirPath = thisExePath.dirName.buildPath("..");

        initTextures();
        initModels();
        initShaders();
        initProgram();
        initAttributesUniforms();
        initVao();
	}

    /** Release all OpenGL resources. */
    ~this() {
        vertexBuffer.release();
        uvBuffer.release();
        texture.remove();

        foreach (shader; shaders)
            shader.release();

        program.release();
	}

    void initTextures()
    {
        string textPath = workDirPath.buildPath("textures/lightmap.png");
        this.texture = Texture2D.from_image(textPath);
    }

    void initModels()
    {
        string modelPath = workDirPath.buildPath("models/room.obj");
        this.model = loadObjModel(modelPath);
        initVertices();
        initUV();
    }

    void initVertices()
    {
        this.vertexBuffer = new GLBuffer(model.vertexArr, UsageHint.staticDraw);
    }

    void initUV()
    {
        this.uvBuffer = new GLBuffer(model.uvArr, UsageHint.staticDraw);
    }

    void initShaders()
    {
        enum vertexShader = q{
            #version 330 core

            // Input vertex data, different for all executions of this shader.
            layout(location = 0) in vec3 vertexPosition_modelspace;

            // this is forwarded to the fragment shader.
            layout(location = 1) in vec2 vertexUV;

            // forward
            out vec2 fragmentUV;

            // Values that stay constant for the whole mesh.
            uniform mat4 mvpMatrix;

            void main()
            {
                // Output position of the vertex, in clip space : mvpMatrix * position
                gl_Position = mvpMatrix * vec4(vertexPosition_modelspace, 1);

                // forward to the fragment shader
                fragmentUV = vertexUV;
            }
        };

        enum fragmentShader = q{
            #version 330 core

            // interpolated values from the vertex shader
            in vec2 fragmentUV;

            // output
            out vec3 color;

            // this is our constant texture. It's constant throughout the running of the program,
            // but can be changed between each run.
            uniform sampler2D textureSampler;

            void main()
            {
                // we pick one of the pixels in the texture based on the 2D coordinate value of fragmentUV.
                color = texture(textureSampler, fragmentUV).rgb;
            }
        };

        this.shaders ~= Shader.fromText(ShaderType.vertex, vertexShader);
        this.shaders ~= Shader.fromText(ShaderType.fragment, fragmentShader);
    }

    void initProgram()
    {
        this.program = new Program(shaders);
    }

    void initAttributesUniforms()
    {
        this.positionAttribute = program.getAttribute("vertexPosition_modelspace");
        this.uvAttribute = program.getAttribute("vertexUV");

        this.mvpUniform = program.getUniform("mvpMatrix");
        this.textureSamplerUniform = program.getUniform("textureSampler");
    }

    void initVao()
    {
        // Note: this must be called when using the core profile,
        // and it must be called before any other OpenGL call.
        // VAOs have a proper use-case but it's not shown here,
        // search the web for VAO documentation and check it out.
        GLuint vao;
        glGenVertexArrays(1, &vao);
        glBindVertexArray(vao);
    }

private:

    // reference to a GPU buffer containing the vertices.
    GLBuffer vertexBuffer;

    // ditto, but containing UV coordinates.
    GLBuffer uvBuffer;

    // the texture we're going to use for the cube.
    Texture2D texture;

    // kept around for cleanup.
    Shader[] shaders;

    // our main GL program.
    Program program;

    // The vertex positions attribute
    Attribute positionAttribute;

    // ditto for the UV coordinates.
    Attribute uvAttribute;

    // The uniform (location) of the matrix in the shader.
    Uniform mvpUniform;

    // Ditto for the texture sampler.
    Uniform textureSamplerUniform;

    // root path where the 'textures' and 'bin' folders can be found.
    const string workDirPath;

	string modelName;
	string textureName;

	Model model;
}

struct MeshManager {
	/// Filename to Mesh*
	Mesh*[string] meshes;
}
