// Dayne
// State
// February 2024

using program_state : struct {
    VERSION :: 0;
    DEBUG_MEMORY :: true;

    mode : enum {
        NORMAL;
        DEBUG;
    }

    using external_components : struct {
        window          : *SDL_Window;
        gl_context      : *SDL_GLContext;
        imgui_context   : *ImGui.ImGuiContext;
    }

    game    : Game;
    editor  : Editor;
    graphics_context    : Graphics_Context;
    audio_context       : Audio_Context;

    // Asset Paths
    sprites_path    :: "assets/sprites";
    fonts_path      :: "assets/fonts";
    music_path      :: "assets/audio/music";
    sfx_path        :: "assets/audio/sfx";
    shaders_path    :: "assets/shaders";

    data_path       :: "assets/data";

    tweaks_path     :: ".";

    // Loose Globals
    scratch_memory  : Flat_Pool;

    ////////////////////////////////////////////////////////////////////////////

    running := true;

    current_scene : Scene = .GAME;
    prior_scene : Scene;

    imgui_capturing_mouse    := false;
    imgui_capturing_keyboard := false;
    framerate : float;
}



// Scene Definition
////////////////////////////////////////////////////////////////////////////////

Scene :: enum {
    TITLE;
    GAME;
    MENU;
    EDITOR;
}

switch_scene :: (new_scene: Scene) {
    using program_state;

    prior_scene = current_scene;
    current_scene = new_scene;
}

return_to_prior_scene :: () {
    using program_state;

    current_scene, prior_scene = swap(current_scene, prior_scene);
}
