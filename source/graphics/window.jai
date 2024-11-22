// Dayne
// Window
// August 2024

using window_constants : struct {
    using viewport :: struct {
        WIDTH :: 14;
        HEIGHT :: 8;
    }

    TILE_SIZE_IN_PIXELS :: 16;

    PIXEL_WIDTH     :: TILE_SIZE_IN_PIXELS * viewport.WIDTH;
    PIXEL_HEIGHT    :: TILE_SIZE_IN_PIXELS * viewport.HEIGHT;
    WINDOW_SCALE_FACTOR :: 8;

    DEFAULT_WINDOW_WIDTH    :: PIXEL_WIDTH  * WINDOW_SCALE_FACTOR;
    DEFAULT_WINDOW_HEIGHT   :: PIXEL_HEIGHT * WINDOW_SCALE_FACTOR;

      GAME_ASPECT_RATIO : float : cast(float)PIXEL_WIDTH / PIXEL_HEIGHT;
    SCREEN_ASPECT_RATIO : float : 16.0 / 9;
}


Window_Context :: struct {
    // Fields
    window_width  : s32 = DEFAULT_WINDOW_WIDTH;
    window_height : s32 = DEFAULT_WINDOW_HEIGHT;

    viewport_width : s32 = cast(s32)(DEFAULT_WINDOW_HEIGHT * GAME_ASPECT_RATIO);
    viewport_height: s32 = DEFAULT_WINDOW_HEIGHT;

    fullscreen: bool;
}

////////////////////////////////////////////////////////////////////////////////

deactivate_mouse :: () {
    SDL_ShowCursor(0);
    SDL_SetRelativeMouseMode(SDL_TRUE);
}

activate_mouse :: () {
    SDL_ShowCursor(1);
    SDL_SetRelativeMouseMode(SDL_FALSE);
    SDL_WarpMouseInWindow(window, graphics_context.window_width / 2, graphics_context.window_height / 2);
}

// Fullscreen / Resolution
////////////////////////////////////////////////////////////////////////////////

go_fullscreen :: () {
    using graphics_context;

    display_mode : SDL_DisplayMode;
    SDL_GetDesktopDisplayMode(0, *display_mode);

    SDL_SetWindowResizable(window, SDL_FALSE);
    SDL_SetWindowBordered(window, SDL_FALSE);
    SDL_SetWindowPosition(window, 0, 0);
    SDL_SetWindowSize(window, display_mode.w, display_mode.h);

    SDL_GetWindowDisplayMode(window, *display_mode);
}

go_windowed :: () {
    using graphics_context;

    display_mode : SDL_DisplayMode;
    SDL_GetDesktopDisplayMode(0, *display_mode);

    SDL_SetWindowResizable(window, SDL_TRUE);
    SDL_SetWindowBordered(window, SDL_TRUE);
    SDL_SetWindowSize(window,
        DEFAULT_WINDOW_WIDTH,
        DEFAULT_WINDOW_HEIGHT
    );
    SDL_SetWindowPosition(window, 
        display_mode.w / 2 - DEFAULT_WINDOW_WIDTH / 2,
        display_mode.h / 2 - DEFAULT_WINDOW_HEIGHT / 2
    );
    SDL_SetWindowResizable(window, SDL_FALSE);

    SDL_GetWindowDisplayMode(window, *display_mode);
}

set_screen_mode_according_to_fullscreen_variable :: () {
    if graphics_context.fullscreen then
        go_fullscreen();
    else
        go_windowed();
}
