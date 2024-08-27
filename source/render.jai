// Dayne
// Render
// August 2024

render :: (game: Game, menu: Menu) {
    // Render everything in this block to the framebuffer.
    {
        glBindFramebuffer(GL_FRAMEBUFFER, graphics_context.fbo);
        glViewport(0, 0, PIXEL_WIDTH, PIXEL_HEIGHT);
        glClearColor(black.x, black.y, black.z, 1);
        glClear(GL_COLOR_BUFFER_BIT);

        if #complete program_state.current_scene == {
            case .TITLE;
                draw_title_screen();

            case .GAME;
                draw_game(game);
                draw_user_interface();

            case .MENU;
                draw_menu(menu);

            case .EDITOR;
                draw_game(game);
                // Editor Rendering is contained in editor.jai
                // due to the nature of imgui.
        }
    }

    render_framebuffer_to_screen();
}

draw_user_interface :: () {
    draw_clock_readout();
}

draw_title_screen :: () {
    draw_text(
        "Fish",
        x = PIXEL_WIDTH / 2,
        y = 7,
        alignment   = Alignment.CENTER,
        progress    = -1,
        font        = .MAIN,
        color       = white,
    );
}

////////////////////////////////////////////////////////////////////////////////

draw_game :: (game : Game) {
    camera_center := Pair.{};

    // Draw Level
    for tile, index : game.level.tiles {
        if tile.kind == .EMPTY then continue;

        pixel : Pair;

        world_column := index % game.level.width;
        world_row    := index / game.level.width;

        pixel.x = world_column * TILE_SIZE_IN_PIXELS;
        pixel.y = world_row    * TILE_SIZE_IN_PIXELS;

        draw_tile(tile, pixel, camera_center);
    }

    // Draw Entities
    {
        // Z Sort em real quick
        {
            comparison :: (a: *Entity, b: *Entity) -> int { 
                if a.z_index > b.z_index        return 1;
                else if a.z_index < b.z_index   return -1;
                else return b.id - a.id;
            }
            quick_sort(game.entities, comparison);
        }

        for entity : game.entities {
            draw_entity(entity, camera_center);
        }

        // Just to test sprites out here...
        /*
        draw_sprite(
            graphics_context.spritesheet,
            index = 3 * 16 + 2,
            pixel = .{48, 64},
        );
        */
    }

    if game.player.state == {
        case .DEFAULT;
    }


    // Debug Overlays
    if program_state.mode == .DEBUG {
        for tile : game.level.tiles {
            draw(tile.collider, color=tile.debug_color);
        }

        for entity : game.entities {
            if entity.kind == {
                case .GUY;
                    draw(entity.collider, color=entity.debug_color);
            }
        }
    }
}
