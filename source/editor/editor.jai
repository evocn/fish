// Dayne
// Editor
// Alex Hartford
// February 2024

#load "imgui_boilerplate.jai";

Editor :: struct {
}

apply_inputs_to_editor :: (editor : *Editor, input: Input) {
}

update_and_draw_editor :: () {
    io := ImGui.GetIO();
    program_state.imgui_capturing_mouse     = io.WantCaptureMouse;
    program_state.imgui_capturing_keyboard  = io.WantCaptureKeyboard;
    program_state.framerate                 = io.Framerate;

    ImGui_ImplSdl_NewFrame(window);
    ImGui.NewFrame();
    {
        editor_functions();

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
        ImGui.RadioButton("Debug",  xx *program_state.mode, 1);
    }
    ImGui.End();
}
