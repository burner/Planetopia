module game.main;

import glwtf.window;
import engine.window;
import engine.programstate;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import deimos.glfw.glfw3;
import dgl;
import glad.gl.all;
import gl3n.math;
import engine.renderer;

/** We're using the Derelict SDL binding for image loading. */
void loadDerelictSDL()
{
    DerelictSDL2.load();
    DerelictSDL2Image.load();
}

void hookCallbacks(Window window, ref ProgramState state)
{
    /**
        We're using a keyboard callback that will update the projection type
        if the user presses the P (perspective) or O (orthographic) keys.
        This will trigger a recalculation of the mvp matrix.
    */
    auto onChangePerspective =
    (int key, int scanCode, int modifier)
    {
        switch (key)
        {
            case GLFW_KEY_P:
                state.projectionType = ProjectionType.perspective;
                break;

            case GLFW_KEY_O:
                state.projectionType = ProjectionType.orthographic;
                break;

            default:
        }
    };

    // hook the callback
    window.on_key_down.strongConnect(onChangePerspective);

    auto onFovChange = (double hOffset, double vOffset)
    {
        // change fov but limit it to a sane range.
        // don't make the upper limit too low or
        // you'll make TotalBiscuit angry. :P
        auto fov = state.fov - (5 * vOffset);
        fov = max(45.0, fov).min(100.0);
        state.fov = fov;
    };

    window.on_scroll.strongConnect(onFovChange);
}

void main()
{
    loadDerelictSDL();

    auto window = createWindow("Tutorial 16 - Shadow Maps");

    // hide the mouse cursor (even when not in client area).
    window.set_input_mode(GLFW_CURSOR, GLFW_CURSOR_DISABLED);

    auto state = ProgramState(window);

    hookCallbacks(window, state);

    // enable z-buffer depth testing.
    glEnable(GL_DEPTH_TEST);

    // accept fragment if it is closer to the camera than another one.
    glDepthFunc(GL_LESS);

    // cull triangles whose normal is not towards the camera.
	glEnable(GL_CULL_FACE);

    while (!glfwWindowShouldClose(window.window))
    {
        /*
            We want to update the camera position (the matrix)
            for every rendered image. Typically the game tick
            is decoupled from the render tick, but for simplicity
            we have a 1:1 match.
        */
        state.gameTick();

        /* Render to the back buffer. */
        render(state);

        /* Swap front and back buffers. */
        window.swap_buffers();

        /* Poll for and process events. */
        glfwPollEvents();

        if (window.is_key_down(GLFW_KEY_ESCAPE))
            glfwSetWindowShouldClose(window.window, true);
    }
}
