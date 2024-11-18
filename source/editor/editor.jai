// Dayne
// Editor
// February 2024

#load "imgui_sdl_gl.jai";

Editor :: struct {
}

apply_inputs_to_editor :: (editor : *Editor, input: Input) {
}

update_and_draw_editor :: (game: *Game) {
    io := ImGui.GetIO();
    program_state.imgui_capturing_mouse     = io.WantCaptureMouse;
    program_state.imgui_capturing_keyboard  = io.WantCaptureKeyboard;
    program_state.framerate                 = io.Framerate;

    ImGui_ImplSdl_NewFrame(window);
    ImGui.NewFrame();
    {
        editor_functions();

        game_editor(game);

        ImGui.ShowDemoWindow();
    }
    ImGui.Render();
}



// Individual Editor Features
////////////////////////////////////////////////////////////////////////////////

editor_functions :: () {
    ImGui.Begin("Editor");
    {
        ImGui.RadioButton("Normal", xx *program_state.mode, 0);
        ImGui.SameLine();
        ImGui.RadioButton("Debug",  xx *program_state.mode, 1);
    }
    ImGui.End();
}

game_editor :: (using game: *Game) {
    ImGui.Begin("Game");
    {
        ImGui.Text("Repopulate");

        if ImGui.Button("time") {
            genocide(game);
            seed := generate_seed_from_date_and_hour();
            populate(game, seed);
        }

        ImGui.SameLine();

        if ImGui.Button("rand") {
            genocide(game);
            seed := generate_seed();
            populate(game, seed);
        }

        ImGui.SameLine();

        if ImGui.Button("all") {
            genocide(game);
            populate_everyone(game);
        }
    }
    ImGui.End();
}
