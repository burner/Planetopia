module engine.programstate;


/// The type of projection we want to use.
enum ProjectionType
{
    perspective,
    orthographic,
}

/**
    Contains all of our OpenGL program state.
    This avoids the use of globals and
    makes the code more maintainable.
*/
struct ProgramState
{
	import engine.window;
	import gl3n.linalg;
	import gl3n.math;
	import glwtf.window;
	import std.file : thisExePath;
	import std.path : buildPath, dirName;
	import deimos.glfw.glfw3;
	import dgl;

    ///
    this(Window window)
    {
        this.window = window;
        this.workDirPath = thisExePath.dirName.buildPath("..");
        this.lastTime = glfwGetTime();

        updateInputControls();
        updateProjection();
    }

    /** Release all OpenGL resources. */
    ~this()
    {
        glfwTerminate();
    }

    /// Get the projection type.
    @property ProjectionType projectionType()
    {
        return _projectionType;
    }

    /// Set a new projection type. This will recalculate the mvp matrix.
    @property void projectionType(ProjectionType newProjectionType)
    {
        if (newProjectionType == _projectionType)
            return;

        _projectionType = newProjectionType;
        updateProjection();
    }

    /// Get the current fov.
    @property float fov()
    {
        return _fov;
    }

    /// Set a new fov. This will recalculate the mvp matrix.
    @property void fov(float newFov)
    {
        if (newFov is fov)  // floats are bit-equal (note: don't ever use '==' with floats)
            return;

        _fov = newFov;
        updateProjection();
    }

    /** Update all the game state. */
    void gameTick()
    {
        updateInputControls();
        updateProjection();
    }

    /**
        Recalculate the projection (e.g. after a FOV change or mouse position change).
        Renamed from initProjection from previous tutorials.
    */
    void updateProjection()
    {
        auto projMatrix = getProjMatrix();
        auto viewMatrix = getViewMatrix();
        auto modelMatrix = getModelMatrix();

        // Remember that matrix multiplication is right-to-left.
        this.mvpMatrix = projMatrix * viewMatrix * modelMatrix;
    }

private:


    /**
        Check the keyboard and mouse input state against the last game tick,
        and update the camera position and view direction.
    */
    void updateInputControls()
    {
        // Compute time difference between current and last frame
        double currentTime = glfwGetTime();
        float deltaTime = cast(float)(currentTime - lastTime);

        // For the next frame, the "last time" will be "now"
        lastTime = currentTime;

        // Get mouse position
        double xpos, ypos;
        glfwGetCursorPos(window.window, &xpos, &ypos);

        // Reset mouse position for the next update.
        glfwSetCursorPos(window.window, 0, 0);

        /** If the window loses focus the values can become too large. */
        xpos = max(-20, xpos).min(20);
        ypos = max(-20, ypos).min(20);

        // Compute the new orientation
        this.horizontalAngle -= this.mouseSpeed * cast(float)xpos;
        this.verticalAngle   -= this.mouseSpeed * cast(float)ypos;

        // Direction - Spherical coordinates to Cartesian coordinates conversion
        this.direction = vec3(
            cos(this.verticalAngle) * sin(this.horizontalAngle),
            sin(this.verticalAngle),
            cos(this.verticalAngle) * cos(this.horizontalAngle)
        );

        // Right vector
        this.right = vec3(
            sin(this.horizontalAngle - 3.14f / 2.0f), // X
            0,                                        // Y
            cos(this.horizontalAngle - 3.14f / 2.0f)  // Z
        );

        alias KeyForward = GLFW_KEY_W;
        alias KeyBackward = GLFW_KEY_S;
        alias KeyStrafeLeft = GLFW_KEY_A;
        alias KeyStrafeRight = GLFW_KEY_D;
        alias KeyClimb = GLFW_KEY_SPACE;
        alias KeySink = GLFW_KEY_LEFT_SHIFT;

        if (window.is_key_down(KeyForward))
        {
            this.position += deltaTime * this.direction * this.speed;
        }

        if (window.is_key_down(KeyBackward))
        {
            this.position -= deltaTime * this.direction * this.speed;
        }

        if (window.is_key_down(KeyStrafeLeft))
        {
            this.position -= deltaTime * right * this.speed;
        }

        if (window.is_key_down(KeyStrafeRight))
        {
            this.position += deltaTime * right * this.speed;
        }

        if (window.is_key_down(KeyClimb))
        {
            this.position.y += deltaTime * this.speed;
        }

        if (window.is_key_down(KeySink))
        {
            this.position.y -= deltaTime * this.speed;
        }

        //~ import std.stdio;
        //~ stderr.writeln(horizontalAngle, " ", verticalAngle);
        //~ stderr.writeln(this.direction);
        //~ stderr.writeln();
    }

    mat4 getProjMatrix()
    {
        final switch (_projectionType) with (ProjectionType)
        {
            case orthographic:
            {
                float left = -10.0;
                float right = 10.0;
                float bottom = -10.0;
                float top = 10.0;
                float near = 0.0;
                float far = 100.0;
                return mat4.orthographic(left, right, bottom, top, near, far);
            }

            case perspective:
            {
                float near = 0.1f;
                float far = 100.0f;

                int width;
                int height;
                glfwGetWindowSize(window.window, &width, &height);
                return mat4.perspective(width, height, _fov, near, far);
            }
        }
    }

    // the view (camera) matrix
    mat4 getViewMatrix()
    {
        // Up vector
        vec3 up = cross(this.right, this.direction);

        return mat4.look_at(
            position,              // Camera is here
            position + direction,  // and looks here
            up                     //
        );
    }

    //
    mat4 getModelMatrix()
    {
        // an identity matrix - the model will be at the origin.
        return mat4.identity();
    }

    // time since the last game tick
    double lastTime = 0;

    // camera position
    vec3 position = vec3(-2.24282, 5.35371, -9.67096);

    // camera direction (note: change horizontalAngle/verticalAngle for the initial direction)
    vec3 direction;

    vec3 right;

    // Initial horizontal angle
    float horizontalAngle = 6.47;

    // Initial vertical angle
    float verticalAngle = -0.198;

    // Initial Field of View
    float initialFoV = 45.0f;

    float speed      = 3.0f; // 3 units / second
    float mouseSpeed = 0.003f;

    // We need the window size to calculate the projection matrix.
    Window window;

    // Selectable projection type.
    ProjectionType _projectionType = ProjectionType.perspective;

    // Field of view (note that this was hardcoded in getProjMatrix in previous tutorials)
    float _fov = 45.0;

    // The currently calculated matrix.
    mat4 mvpMatrix;

private:
	string workDirPath;
}
