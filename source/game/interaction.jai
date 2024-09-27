// Dayne
// Player Interaction
// September 2024

simulate_interactions :: (game: *Game) {
    using game.player.input;

    if mouse_active {
        hover_guy : *Guy;
        for game.entities {
            if it.kind != .GUY then continue;
            guy := cast(*Guy)it;
            if within(mouse_position, guy.collider) {
                hover_guy = guy;
                // @TODO: Resolve z collisions properly.
            }
        }

        if hover_guy {
            if left_mouse.just_pressed {
                guy_trigger_shock(hover_guy);
            }

            if right_mouse.just_pressed {
                guy_trigger_sleep(hover_guy);
            }
        }
    }

    if south.just_pressed {
        sleep_everyone(game);
    }

    if west.just_pressed {
        shock_everyone(game);
    }
}

shock_everyone :: (game : *Game) {
    for game.entities {
        if it.kind != .GUY then continue;
        guy := cast(*Guy)it;
        guy_trigger_shock(guy);
    }
}

sleep_everyone :: (game : *Game) {
    for game.entities {
        if it.kind != .GUY then continue;
        guy := cast(*Guy)it;
        guy_trigger_sleep(guy);
    }
}

guy_trigger_sleep :: (guy: *Guy) {
    guy.personality.current_whim = xx *guy.personality.sleep_behavior;
    reset(guy.personality.current_whim);
}

guy_trigger_shock :: (guy: *Guy) {
    guy.personality.current_whim = xx *guy.personality.shock_behavior;
    reset(guy.personality.current_whim);
}
