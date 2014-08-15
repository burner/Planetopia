module engine.renderer;

import engine.programstate;
import dgl;
import glad.gl.all;

/** Our main render routine. */
void render(ref ProgramState state)
{
    //glClearColor(0.0f, 0.0f, 0.4f, 0.0f);  // dark blue
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    //state.program.bind();

    //// set this to true when converting matrices from row-major order
    //// to column-major order. Note that gl3n uses row-major ordering,
    //// unlike the C++ glm library.
    //enum doTranspose = GL_TRUE;
    //enum matrixCount = 1;
    //glUniformMatrix4fv(state.mvpUniform.ID, matrixCount, doTranspose, &state.mvpMatrix[0][0]);

    //bindTexture(state);
    //bindPositionAttribute(state);
    //bindUVAttribute(state);

    //enum startIndex = 0;

    //// note that unlike in previous tutorials 'vertexArr' here is of type vec3[],
    //// not float[]. Hence using .length here is appropriate. If you used a plain float[]
    //// where each vertex consists of 3 consecutive floats then you would have to divide
    //// the length by 3.
    //const vertexCount = state.model.vertexArr.length;
    //glDrawArrays(GL_TRIANGLES, startIndex, vertexCount);

    //state.texture.unbind();

    //state.positionAttribute.disable();
    //state.vertexBuffer.unbind();

    //state.uvAttribute.disable();
    //state.uvBuffer.unbind();

    //state.program.unbind();
}

void bindPositionAttribute(ref ProgramState state)
{
    //enum int size = 3;  // (x, y, z) per vertex
    //enum GLenum type = GL_FLOAT;
    //enum bool normalized = false;
    //enum int stride = 0;
    //enum int offset = 0;

    //state.vertexBuffer.bind(state.positionAttribute, size, type, normalized, stride, offset);
    //state.positionAttribute.enable();
}

void bindUVAttribute(ref ProgramState state)
{
    //// (u, v) per vertex
    //enum int size = 2;
    //enum GLenum type = GL_FLOAT;
    //enum bool normalized = false;
    //enum int stride = 0;
    //enum int offset = 0;

    //state.uvBuffer.bind(state.uvAttribute, size, type, normalized, stride, offset);
    //state.uvAttribute.enable();
}

void bindTexture(ref ProgramState state)
{
    // set our texture sampler to use Texture Unit 0
    //enum textureUnit = 0;
    //state.program.setUniform1i(state.textureSamplerUniform, textureUnit);

    //state.texture.activate();
    //state.texture.bind();
}
