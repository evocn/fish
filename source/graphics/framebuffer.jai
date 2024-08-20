// Dayne
// Graphics Framebuffer
// Alex Hartford
// August 2024

initialize_framebuffer :: () {
    using graphics_context;

    glGenFramebuffers(1, *fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);

    glGenTextures(1, *render_texture);
    // "Bind" the newly created texture : all future texture functions will modify this texture
    glBindTexture(GL_TEXTURE_2D, render_texture);
    // Give an empty image to OpenGL
    glTexImage2D(GL_TEXTURE_2D, 0,GL_RGBA, PIXEL_WIDTH, PIXEL_HEIGHT, 0,GL_RGBA, GL_UNSIGNED_BYTE, cast(*void)0);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glBindTexture(GL_TEXTURE_2D, 0);

    glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, render_texture, 0);

    // Set the list of draw buffers.
    draw_buffers := GLenum.[GL_COLOR_ATTACHMENT0];
    glDrawBuffers(1, draw_buffers.data);

    result := glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if result != GL_FRAMEBUFFER_COMPLETE {
        log_error("Framebuffer problems. Result code: %\n", result);
        assert(false);
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

draw_screen_quad :: (shader: Shader) {
    using graphics_context;

    viewport_portion_of_the_screen_in_x := cast(float)viewport_height / window_height;
    viewport_portion_of_the_screen_in_y := cast(float)viewport_width / window_width;

    model := Matrix4_Identity;
        // Scale
        default_scale_x :: 2;
        default_scale_y :: 2;

        scale_x : float = default_scale_x * viewport_portion_of_the_screen_in_x;
        scale_y : float = default_scale_y * viewport_portion_of_the_screen_in_y;
        scale_vector := Vector3.{scale_y, scale_x, 1};

        // Translate
        default_translate_x :: -1;
        default_translate_y :: -1;

        translate_x : float = default_translate_x * viewport_portion_of_the_screen_in_y;
        translate_y : float = default_translate_y * viewport_portion_of_the_screen_in_x;
        translation_vector := Vector3.{translate_x, translate_y, 1};

        translate(*model, translation_vector);
        scale(*model, scale_vector);
    set_mat4(shader, "model", model);

    draw_quad(quad);
}

// Renders the framebuffer as a texture on a screen-space quad.
render_framebuffer_to_screen :: () {
    using graphics_context;

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glViewport(0, 0, xx window_width, xx window_height);
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    shader := quad_shader;
    use_shader(shader);
    defer disable_shaders();

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, render_texture);

    draw_screen_quad(shader);
}
