// Dayne
// Guy (Entity)
// August 2024

Guy :: struct {
    using entity: Entity;
    kind = .GUY;
    
    name : string;

    using actor : Actor;
    speed       : float;
    ai          : AI_Controller;

    animations  : [..] Sprite_Animation;
    animation   : *Sprite_Animation;

    // State
    facing_left : bool;     @NoSerialize
    velocity    : Vector2;  @NoSerialize
}

initialize :: (using guy: *Guy) {
    facing_left = false;
    velocity = .{};
}

update :: (using guy: *Guy, dt: float) {
    // AI update
    {
        something_new := update(*ai, dt);

        if something_new {
            apply_ai_to_guy(guy, ai);
        }
    }

    // Move
    {
        amount_to_move := velocity * dt;

        collided_x := move_x(*guy.actor, amount_to_move.x, null);
        if collided_x then velocity.x = -1 * velocity.x;

        collided_y := move_y(*guy.actor, amount_to_move.y, null);
        if collided_y then velocity.y = -1 * velocity.y;

        if collided_x || collided_y then play_sfx("bump", true);

        // Collisions with the level
        {
            extents := game.level.pixel_extents;

            collided_x := (x < extents.x)
                       || (x + width > extents.width)
            ;
            collided_y := (y < extents.y)
                       || (y + height > extents.height)
            ;

            if collided_x {
                x = clamp(x, xx extents.x, xx (extents.x + extents.width - width));
                x_remainder = 0.0;
                velocity.x = -1 * velocity.x;
            }
            if collided_y {
                y = clamp(y, xx extents.y, xx (extents.y + extents.height - height));
                y_remainder = 0.0;
                velocity.y = -1 * velocity.y;
            }

            if collided_x || collided_y then play_sfx("bump", true);
        }
    }


    update_visuals :: (using guy: *Guy, dt: float) {
        // Facing direction
        if velocity.x < 0.0 {
            facing_left = true;
        }
        else if velocity.x > 0.0 {
            facing_left = false;
        }

        // Update Animation
        if guy.ai.state == .WANDER_FLOOR {
            if guy.velocity.x == 0.0 && guy.velocity.y == 0.0 {
                animation = *animations[0];
            }
            else {
                animation = *animations[1];
            }
        }

        update(animation, dt);
    }
    update_visuals(guy, dt);
}

draw :: (guy: *Guy) {
    screen_pixel := world_space_to_screen_pixel(guy.x, guy.y);

    bottom_left_corner_of_sprite :=
          screen_pixel                  // Bottom left corner of collider
        + .{guy.width / 2, 0}           // Gets us the center bottom of collider
        - .{TILE_SIZE_IN_PIXELS / 2, 0} // Bottom left corner!
    ;

    sprite := table_find_pointer(*graphics_context.sheets, guy.animation.sheet);
    if !sprite {
        log_error("Couldn't load entity spritesheet.\n");
        return;
    }

    draw_sprite(
        sprite,
        index = guy.animation.frame,
        pixel = bottom_left_corner_of_sprite,

        scale_factor = 1,

        horizontal_flip = guy.facing_left,

        use_color_override = false,
    );
}

draw_debug :: (guy: *Guy) {
    draw(guy.collider, color=guy.debug.unique_color);
}


// Utilities

get_camera_centered_on_guy :: (guy: Guy) -> Pair {
    camera_center := 
        .{guy.x, guy.y}                                     // Start with the guy's bottom left corner
      + .{TILE_SIZE_IN_PIXELS / 2, TILE_SIZE_IN_PIXELS / 2} // Half the tile size to center on the main character
      + .{0, PIXEL_HEIGHT / 3}                              // Plus a little to bring the camera up a smidge
      - .{PIXEL_WIDTH / 2, PIXEL_HEIGHT / 2}                // Offset the camera to the bottom right corner
    ;

    return camera_center;
}
