// Dayne
// Render
// August 2024

render :: (game: Game, menu: Menu) {
    // render everything in this block to the framebuffer.
    {
        glBindFramebuffer(GL_FRAMEBUFFER, graphics_context.fbo);
        glViewport(0, 0, PIXEL_WIDTH, PIXEL_HEIGHT);
        glClearColor(black.x, black.y, black.z, 1);
        glClear(GL_COLOR_BUFFER_BIT);

        if #complete program_state.current_scene == {
            case .TITLE;
                draw_title_screen();
                draw_version_indicator();

            case .GAME;
                draw_game(game);
                draw_user_interface();

            case .MENU;
                draw_menu(menu);
                draw_version_indicator();

            case .EDITOR;
                draw_game(game);
                // editor rendering is contained in editor.jai.
        }
    }

    render_framebuffer_to_screen();
}

draw_user_interface :: () {
    draw_clock_readout();
}

draw_title_screen :: () {
    draw_text(
        "Placeholder title screen",
        x = PIXEL_WIDTH / 2,
        y = PIXEL_HEIGHT - 15,
        alignment   = Alignment.CENTER,
        progress    = -1,
        font        = .MAIN,
        color       = white,
    );

    draw_text(
        "This is just a little fish tank simulation.",
        x = PIXEL_WIDTH / 2,
        y = 50,
        alignment   = Alignment.CENTER,
        progress    = -1,
        font        = .SMALL,
        color       = white,
    );

    draw_text(
        "Press H to start.",
        x = PIXEL_WIDTH / 2,
        y = 15,
        alignment   = Alignment.CENTER,
        progress    = -1,
        font        = .SMALL,
        color       = white,
    );
}

draw_version_indicator :: () {
    draw_text(
        tprint("fish - version %", VERSION),
        x = 1,
        y = 1,
        alignment = Alignment.LEFT,
        progress = -1,
        font = .SMALL,
        color = green,
    );
}

////////////////////////////////////////////////////////////////////////////////

draw_game :: (game : Game) {
    // Draw Level
    for tile, index : game.level.tiles {
        if tile.kind == .EMPTY then continue;

        pixel : Pair;

        world_column := index % game.level.width;
        world_row    := index / game.level.width;

        pixel.x = world_column * TILE_SIZE_IN_PIXELS;
        pixel.y = world_row    * TILE_SIZE_IN_PIXELS;

        draw_tile(tile, pixel);
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
            draw(entity);
        }
    }


    // Special Code per player state?
    if game.player.state == {
        case .DEFAULT;
    }


    // Debug Overlays
    if program_state.mode == .DEBUG {
        // Draw Colliders
        {
            for tile : game.level.tiles {
                draw(tile.collider, color=tile.debug_color);
            }

            for entity : game.entities {
                draw_debug(entity);
            }
        }
    }
}
