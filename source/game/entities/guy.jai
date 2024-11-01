// Dayne
// Guy (Entity)
// August 2024

Guy :: struct {
    using entity: Entity;
    kind = .GUY;
    
    name : string;

    using actor : Actor;

    personality : Personality;

    animation   : *Sprite_Animation;

    rarity : Rarity;

    // State
    facing_left : bool;     @NoSerialize
    velocity    : Vector2;  @NoSerialize
}

initialize :: (using guy: *Guy) {
    facing_left = false;
    velocity = .{};
}

update :: (using guy: *Guy, dt: float) {
    // Personality update
    {
        update(*personality, guy, dt);

        update_from_gravity :: (using guy: *Guy, dt: float) {
            grounded := check_if_grounded(*guy.actor);
            if grounded then return;

            gravity_velocity := 10.0;

            guy.velocity.y -= gravity_velocity * dt;
        }

        if !personality.current_whim.swimming {
            update_from_gravity(guy, dt);
        }
    }

    // Move
    {
        amount_to_move := velocity * dt;

        collided_x := move_x(*guy.actor, amount_to_move.x, null);
        if collided_x then velocity.x = 0;

        collided_y := move_y(*guy.actor, amount_to_move.y, null);
        if collided_y then velocity.y = 0;

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
    }
    update_visuals(guy, dt);
}

draw :: (using guy: *Guy) {
    sprite := table_find_pointer(*graphics_context.sheets, animation.sheet);
    if !sprite {
        log_error("Couldn't load entity spritesheet %.\n", animation.sheet);
        return;
    }

    screen_pixel := world_space_to_screen_pixel(xx x, xx y);

    bottom_left_corner_of_sprite :=
          screen_pixel    // Bottom left corner of collider
        + .{width / 2, 0} // Gets us the center bottom of collider
        - .{sprite.tile_width_in_pixels / 2, 0} // Bottom left corner!
    ;

    draw_sprite(
        sprite,
        index = animation.frame,
        pixel = bottom_left_corner_of_sprite,

        scale_factor = 1,

        horizontal_flip = facing_left,

        use_color_override = false,
    );
}

draw_debug :: (using guy: *Guy) {
    draw(collider, color=debug.unique_color);
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


////////////////////////////////////////////////////////////////////////////////

Rarity :: enum #complete {
    COMMON;
    RARE;
    MYTHIC;
}

// Tweakable!
get_probability :: (rarity: Rarity) -> float {
    if #complete rarity == {
        case .COMMON; return 0.25;
        case .RARE;   return 0.1;
        case .MYTHIC; return 0.05;
    }
}
