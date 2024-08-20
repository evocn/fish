// Dayne
// Guy
// August 2024

Guy :: struct {
    using #as entity : Entity;
    kind = .GUY;

    ai : AI_Controller;

    speed : float;
    SPRINT_MODIFIER :: 2;

    animation_state : Guy_Animation_State;
    animation_sleep : Animation_Integer;
    animation_idle  : Animation_Integer;
    animation_walk  : Animation_Integer;
    animation_talk  : Animation_Integer;
    animation_dance : Animation_Integer;
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


// Animation logic

Guy_Animation_State :: enum {
    SLEEP;
    IDLE;
    WALK;
    TALK;
    DANCE;
}


go_to_state :: (guy: *Guy, new_state: Guy_Animation_State) {
    if guy.animation_state == new_state then return;
    guy.animation_state = new_state;

    if #complete guy.animation_state == {
        case .SLEEP;
            start(*guy.animation_sleep);

        case .IDLE;
            start(*guy.animation_idle);

        case .WALK;
            start(*guy.animation_walk);

        case .TALK;
            start(*guy.animation_talk);

        case .DANCE;
            start(*guy.animation_dance);
    }
}

update_active_animation :: (guy: *Guy, dt: float) {
    if guy.animation_state == {
        case .SLEEP;
            update(*guy.animation_sleep, dt);

        case .IDLE;
            update(*guy.animation_idle, dt);

        case .WALK;
            update(*guy.animation_walk, dt);

        case .TALK;
            update(*guy.animation_talk, dt);

        case .DANCE;
            update(*guy.animation_dance, dt);
    }
}


// Utilities

get_camera_centered_on_guy :: (guy: Guy) -> Pair {
    camera_center := 
        to_pair(get_position(guy))                          // Start with the guy's bottom left corner
      + .{TILE_SIZE_IN_PIXELS / 2, TILE_SIZE_IN_PIXELS / 2} // Half the tile size to center on the main character
      + .{0, PIXEL_HEIGHT / 3}                              // Plus a little to bring the camera up a smidge
      - .{PIXEL_WIDTH / 2, PIXEL_HEIGHT / 2}                // Offset the camera to the bottom right corner
    ;

    return camera_center;
}
