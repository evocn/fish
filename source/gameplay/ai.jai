// Dayne
// AI
// August 2024

AI_Controller :: struct {
    state : State;

    wants_to_move_this_direction : Vector2;

    period : float = 2.0;
    time : float;

    home_base : Vector2;

    State :: enum {
        SIT;
        WANDER;
        SPIN;
    }
}


update :: (ai: *AI_Controller, dt: float) -> something_new: bool {
    ai.time += dt;
    if ai.state == {
        case .SIT;
            ai.wants_to_move_this_direction = .{};
            return true;

        case .WANDER;
            if ai.time > ai.period {
                ai.time = 0.0;
                if random_get_zero_to_one() >= 0.5 {
                    // Any direction
                    ai.wants_to_move_this_direction = get_random_direction_vector_on_unit_circle();

                    /*
                    // Left or right
                    if random_get_zero_to_one() >= 0.5 {
                        ai.wants_to_move_this_direction = .{1, 0};
                    }
                    else {
                        ai.wants_to_move_this_direction = .{-1, 0};
                    }
                    */
                }

                return true;
            }

        case .SPIN;
            if ai.wants_to_move_this_direction == .{} then ai.wants_to_move_this_direction = .{1, 0};

            if ai.time > ai.period {
                ai.time = 0.0;
                ai.wants_to_move_this_direction = -ai.wants_to_move_this_direction;

                return true;
            }
    }

    return false;
}


apply_ai_to_guy :: (guy: *Guy, ai: AI_Controller) {
    // Calculate Velocity based on AI
    {
        direction : Vector2;

        direction = ai.wants_to_move_this_direction;

        guy.velocity = normalize(direction);

        speed : float;
        speed = guy.speed;

        guy.velocity *= speed;
    }
}
