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

    bird : *Guy = xx new_entity(*game.entities, .GUY);
    {
        bird.sprite = 0;
        bird.color = yellow;

        bird.x = 0;
        bird.y = 16;
        bird.width  = 8;
        bird.height = 10;

        bird.ai.state = .WANDER;

        bird.speed = 45;

        array_add(*simulation.actors, bird);

        bird.animation_sleep = animation_integer_make(
            value = *bird.sprite,
            duration = 1.0,
            keyframes = ...[
                .{0.0, 12},
            ],
        );

        bird.animation_idle = animation_integer_make(
            value = *bird.sprite,
            duration = 0.6,
            keyframes = ...[
                .{0.0, 0},
                .{0.4, 1},
            ],
        );

        bird.animation_walk = animation_integer_make(
            value = *bird.sprite,
            duration = 0.6,
            keyframes = ...[
                .{0.0,  8},
                .{0.15, 9},
                .{0.3,  10},
                .{0.45, 11},
            ],
        );

        bird.animation_talk = animation_integer_make(
            value = *bird.sprite,
            duration = 0.4,
            keyframes = ...[
                .{0.0,   14},
                .{0.25,  15},
            ],
        );

        bird.animation_dance = animation_integer_make(
            value = *bird.sprite,
            duration = 0.6,
            keyframes = ...[
                .{0.0,  4},
                .{0.15, 5},
                .{0.3,  6},
                .{0.45, 7},
            ],
        );
    }

    mouse : *Guy = xx new_entity(*game.entities, .GUY);
    {
        mouse.sprite = 18;
        mouse.color = pink;

        mouse.speed = 5;

        mouse.x = 32;
        mouse.y = 16;
        mouse.width  = 4;
        mouse.height = 4;

        mouse.ai.state = .SPIN;

        array_add(*simulation.actors, mouse);

        mouse.animation_idle = animation_integer_make(
            value = *mouse.sprite,
            duration = 1.5,
            keyframes = ...[
                .{0.0, 20},
                .{0.8, 21},
                .{1.0, 20},
                .{1.3, 21},
            ],
        );

        mouse.animation_walk = animation_integer_make(
            value = *mouse.sprite,
            duration = 0.3,
            keyframes = ...[
                .{0.0,  21},
                .{0.15, 22},
            ],
        );

        mouse.animation_sleep = animation_integer_make(
            value = *mouse.sprite,
            duration = 1.0,
            keyframes = ...[
                .{0.0,  23},
            ],
        );

        mouse.animation_talk   = mouse.animation_idle;
        mouse.animation_dance  = mouse.animation_idle;
    }


    frog : *Guy = xx new_entity(*game.entities, .GUY);
    {
        frog.sprite = 16;
        frog.color = green;

        frog.x = 100;
        frog.y = 16;
        frog.width  = 12;
        frog.height = 12;

        frog.speed = 10;

        frog.ai.state = .WANDER;

        array_add(*simulation.actors, frog);

        frog.animation_idle = animation_integer_make(
            value = *frog.sprite,
            duration = 2.0,
            keyframes = ...[
                .{0.0, 16},
                .{1.0, 17},
            ],
        );

        frog.animation_walk = animation_integer_make(
            value = *frog.sprite,
            duration = 0.8,
            keyframes = ...[
                .{0.0, 18},
                .{0.2, 16},
                .{0.4, 19},
                .{0.6, 17},
            ],
        );

        frog.animation_sleep = animation_integer_make(
            value = *frog.sprite,
            duration = 1.0,
            keyframes = ...[
                .{0.0, 16},
            ],
        );

        frog.animation_talk   = frog.animation_idle;
        frog.animation_dance  = frog.animation_idle;
    }

    dog : *Guy = xx new_entity(*game.entities, .GUY);
    {
        dog.sprite = 16;
        dog.color = blue;

        dog.x = 128;
        dog.y = 16;
        dog.width  = 10;
        dog.height = 8;

        dog.speed = 100;

        dog.ai.state = .WANDER;

        array_add(*simulation.actors, dog);

        dog.animation_idle = animation_integer_make(
            value = *dog.sprite,
            duration = 1.0,
            keyframes = ...[
                .{0.0, 28},
                .{7.0, 29},
            ],
        );

        dog.animation_walk = animation_integer_make(
            value = *dog.sprite,
            duration = 0.5,
            keyframes = ...[
                .{0.0, 28},
                .{0.2, 29},
            ],
        );

        dog.animation_sleep = animation_integer_make(
            value = *dog.sprite,
            duration = 1.0,
            keyframes = ...[
                .{0.0, 28},
            ],
        );

        dog.animation_talk   = dog.animation_idle;
        dog.animation_dance  = dog.animation_idle;
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
