// Dayne
// Guy (Entity)
// August 2024

Guy :: struct {
    using entity : Entity;
    kind = .GUY;

    ai : AI_Controller;

    // Simulation
    using actor : Actor;
    velocity    : Vector2; @NoSerialize

    // Appearance
    facing_left : bool;
    sheet : string;
    sprite  : int;
    frame   : int = 0; @NoSerialize


    speed : float;
    SPRINT_MODIFIER :: 2; @NoSerialize

    animation_state : Guy_Animation_State;

    animation_idle  : Animation_Integer;
    animation_walk  : Animation_Integer;
}

initialize :: (using guy: *Guy) {
    animation_idle.value = *frame;
    animation_walk.value = *frame;
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
        }
    }


    update_visuals :: (guy: *Guy, dt: float) {
        // Facing direction
        if guy.velocity.x < 0.0 {
            guy.facing_left = true;
        }
        else if guy.velocity.x > 0.0 {
            guy.facing_left = false;
        }

        // Animation State
        if guy.velocity.x == 0.0 && guy.velocity.y == 0.0 {
            go_to_state(guy, .IDLE);
        }
        else {
            go_to_state(guy, .WALK);
        }

        // Update Animation
        update_active_animation(guy, dt);
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

    sprite := table_find_pointer(*graphics_context.sheets, guy.sheet);
    if !sprite {
        log_error("Couldn't load entity spritesheet.\n");
        return;
    }

    draw_sprite(
        sprite,
        index = (guy.sprite * sprite.columns) + guy.frame,
        pixel = bottom_left_corner_of_sprite,

        scale_factor = 1,

        horizontal_flip = guy.facing_left,

        use_color_override = false,
    );
}

draw_debug :: (guy: *Guy) {
    draw(guy.collider, color=guy.debug.unique_color);
}


// Animation logic

Guy_Animation_State :: enum {
    IDLE;
    WALK;
}


go_to_state :: (guy: *Guy, new_state: Guy_Animation_State) {
    if guy.animation_state == new_state then return;
    guy.animation_state = new_state;

    if #complete guy.animation_state == {
        case .IDLE;     start(*guy.animation_idle);
        case .WALK;     start(*guy.animation_walk);
    }
}

update_active_animation :: (guy: *Guy, dt: float) {
    if guy.animation_state == {
        case .IDLE;     update(*guy.animation_idle, dt);
        case .WALK;     update(*guy.animation_walk, dt);
    }
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
