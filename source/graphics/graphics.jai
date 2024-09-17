// Dayne
// Graphics Rendering
// August 2024

// This set of files governs drawing stuff to the screen.
// * Window sizing / context
// * Shaders
// * Textures
// * Primitives
// * Text

#load "window.jai";
#load "draw.jai";
#load "primitives.jai";
#load "shader.jai";
#load "texture.jai";
#load "framebuffer.jai";
#load "sprite.jai";
#load "color.jai";
#load "text.jai";

Graphics_Context :: struct {
    using window_context : Window_Context;

    using shaders : struct {
        basic_shader    : Shader;
        sprite_shader   : Shader;
        text_shader     : Shader;
        quad_shader     : Shader;
    }

    // Primitives for drawing things
    quad : Quad;

    sprites : Table(string, Sprite);
    sheets : Table(string, Sprite);

    fbo : GLuint;
    render_texture : GLuint;

    // Fonts
    main_font  : Font;
    small_font : Font;
}


print_gl_errors :: (str := "-") {
    if dont_check_for_gl_errors_anymore then return;

    current_error : GLenum;
    current_error = glGetError();
    while current_error != GL_NO_ERROR {
        dont_check_for_gl_errors_anymore = true;

        log_error("OpenGL Error(%) = %\n", str, current_error);

        current_error = glGetError();
    }
}
dont_check_for_gl_errors_anymore : bool;
