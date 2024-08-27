// Dayne
// Main
// August 2024

main :: () {
    initialize_everything();

    gamepad: SDL_Joystick;

    main_menu := menu_initialize();

    play_music("nagata");


    // Load Level from file

    load_overworld_tiles_from_level_file :: () {
        raw_text, success := read_entire_file(tprint("%/%", data_path, "1.tank"));
        stripped_newlines, line_count := replace(raw_text, "\r\n", "");
        assert(line_count == game.level.height, "Uh oh.. Problem with the text file.\n");

        for character, index : cast([]u8)stripped_newlines {
            new_tile := *game.level.tiles[index];

            new_tile.* = get_tile_from_catalogue(character - 48);
            new_tile.debug_color = get_random_color();

            if game.level.tiles[index].kind == .SOLID {
                tile_position := get_tile_position_from_level_index(game.level, index);
                new_tile.x = tile_position.x;
                new_tile.y = tile_position.y;

                array_add(*simulation.solids, *new_tile.solid);
            }
        }
    }
    load_overworld_tiles_from_level_file();


    // Load Entities (Hardcoded for now)

    blowfish : *Guy = xx new_entity(*game.entities, .GUY);
    {
        blowfish.sprite = 2;

        blowfish.x = 0;
        blowfish.y = 16;
        blowfish.width  = 14;
        blowfish.height = 14;

        blowfish.ai.state = .DEBUG;

        blowfish.speed = 150;

        array_add(*simulation.actors, blowfish);

        blowfish.animation_sleep = animation_integer_make(
            value = *blowfish.frame,
            duration = 2.0,
            keyframes = ...[
                .{0.0, 4},
                .{1.0, 5},
            ],
        );

        blowfish.animation_idle = animation_integer_make(
            value = *blowfish.frame,
            duration = 1.0,
            keyframes = ...[
                .{0.0, 1},
            ],
        );

        blowfish.animation_walk = animation_integer_make(
            value = *blowfish.frame,
            duration = 1.0,
            keyframes = ...[
                .{0.0, 7},
            ],
        );

        blowfish.animation_talk = animation_integer_make(
            value = *blowfish.frame,
            duration = 0.4,
            keyframes = ...[
                .{0.0,   9},
                .{0.25,  10},
            ],
        );

        blowfish.animation_dance = animation_integer_make(
            value = *blowfish.frame,
            duration = 0.6,
            keyframes = ...[
                .{0.0,  10},
                .{0.15, 0},
            ],
        );
    }

    jellyfish : *Guy = xx new_entity(*game.entities, .GUY);
    {
        jellyfish.sprite = 1;

        jellyfish.speed = 6;

        jellyfish.x = 32;
        jellyfish.y = 16;
        jellyfish.width  = 4;
        jellyfish.height = 4;

        jellyfish.ai.state = .SPIN;

        array_add(*simulation.actors, jellyfish);

        jellyfish.animation_idle = animation_integer_make(
            value = *jellyfish.frame,
            duration = 0.8,
            keyframes = ...[
                .{0.0, 0},
                .{0.4, 1},
            ],
        );

        jellyfish.animation_walk = animation_integer_make(
            value = *jellyfish.frame,
            duration = 0.3,
            keyframes = ...[
                .{0.0,  2},
                .{0.15, 3},
            ],
        );

        jellyfish.animation_sleep = animation_integer_make(
            value = *jellyfish.frame,
            duration = 3.0,
            keyframes = ...[
                .{0.0,  4},
                .{1.5,  5},
            ],
        );

        jellyfish.animation_talk   = jellyfish.animation_idle;
        jellyfish.animation_dance  = jellyfish.animation_idle;
    }


    frog : *Guy = xx new_entity(*game.entities, .GUY);
    {
        frog.sprite = 3;

        frog.x = 100;
        frog.y = 16;
        frog.width  = 12;
        frog.height = 12;

        frog.speed = 10;

        frog.ai.state = .WANDER;

        array_add(*simulation.actors, frog);

        frog.animation_idle = animation_integer_make(
            value = *frog.frame,
            duration = 2.0,
            keyframes = ...[
                .{0.0, 0},
                .{1.0, 1},
            ],
        );

        frog.animation_walk = animation_integer_make(
            value = *frog.frame,
            duration = 0.8,
            keyframes = ...[
                .{0.0, 2},
                .{0.2, 0},
                .{0.4, 3},
                .{0.6, 1},
            ],
        );

        frog.animation_sleep = animation_integer_make(
            value = *frog.frame,
            duration = 1.5,
            keyframes = ...[
                .{0.0, 4},
                .{0.5, 5},
            ],
        );

        frog.animation_talk   = frog.animation_idle;
        frog.animation_dance  = frog.animation_idle;
    }

    dt, last_frame := 0.0;
    while program_state.running {
        ////////////////////////////////////////////////////////////////////////////////
        // Frame Startup
        {
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Input
        {
            gather_input(*game.player.input, *gamepad);

            defer {
                post_frame_update(*game.player.input);
            }

            // Dispatch Inputs based on program state
            if #complete program_state.current_scene == {
                case .TITLE;
                    if game.player.input.south.just_pressed {
                        switch_scene(.GAME);
                    }

                case .GAME;
                    if game.player.input.start.just_pressed {
                        switch_scene(.MENU);
                    }

                    if #complete game.player.state == {
                        case .DEFAULT;
                    }

                case .MENU;
                    apply_inputs_to_menu(*main_menu, game.player.input);

                case .EDITOR;
                    apply_inputs_to_editor(*editor, game.player.input);
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Simulate
        {
            rainbow_color = update_rainbow_color(dt);

            if #complete program_state.current_scene == {
                case .TITLE;

                case .GAME;
                    simulate(*game, dt);

                case .MENU;
                case .EDITOR;
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Render
        render(
            game,
            main_menu,
        );

        if program_state.current_scene == .EDITOR {
            update_and_draw_editor();
            ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        }

        SDL_GL_SwapWindow(window);
        SDL_Delay(1);

        ////////////////////////////////////////////////////////////////////////////////
        // Frame Cleanup
        {

            current_time := cast(float32)seconds_since_init();
            dt = current_time - last_frame;
            last_frame = current_time;

            reset_temporary_storage();
        }
    }

    cleanup_for_shutdown(*main_menu);

    #if DEBUG_MEMORY then report_memory_leaks();
}


////////////////////////////////////////////////////////////////////////////////
// Imports
////////////////////////////////////////////////////////////////////////////////

// Standard Library files
using Basic :: #import "Basic"()(MEMORY_DEBUGGER=DEBUG_MEMORY);
#import "Flat_Pool";
#import "String";
#import "Math";
#import "Hash_Table";
#import "File";
#import "Text_File_Handler";
#import "Sort";
File_Utilities :: #import "File_Utilities"; // For file_list()
System         :: #import "System";         // For get_path_of_running_executable()
#import "Random";


// Third Party Dependencies
#import "SDL";
#import "GL";
ImGui :: #import "ImGui";
#import "stb_image";
#import "freetype-2.12.1";
#import "miniaudio";


// Loads
////////////////////////////////////////////////////////////////////////////////
#load "initialize.jai";
#load "state.jai";
#load "game.jai";
#load "render.jai";

// Core
#load "core/utils.jai";
#load "core/input.jai";
#load "core/player.jai";
#load "core/tweaks.jai";
#load "core/menu.jai";

// Subsystems
#load "gameplay/gameplay.jai";
#load "graphics/graphics.jai";
#load "audio/audio.jai";

#load "animation/animation.jai";

#load "editor/editor.jai";
