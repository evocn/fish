// Dayne
// Behavior
// September 2024

// A Behavior is an AI controller for an entity. It tells an entity what to do at a given time.

Behavior :: struct {
    Kind :: enum {
        SLEEP;
        SHOCK;
        HEART;

        IDLE;
        WANDER;
        WANDER_FLOOR;
        SPIN;

        DEBUG;
    }
    kind : Kind;

    animation : Sprite_Animation;

    // @TODO: Should these choice-level variables be kept in the Personality? Or in the individual behaviors?
    default_boredom := 7.0;
    boredom : float;
    excitement_factor   := 1;

    // State
    time : float; @NoSerialize
}

update :: (behavior: *Behavior, guy: *Guy, dt: float) {
    behavior.time += dt;
    if behavior.kind == {
        case .SLEEP;        update(cast(*Behavior_Sleep)behavior,       guy, dt);
        case .SHOCK;        update(cast(*Behavior_Shock)behavior,       guy, dt);
        case .HEART;        update(cast(*Behavior_Heart)behavior,       guy, dt);
        case .IDLE;         update(cast(*Behavior_Idle)behavior,        guy, dt);
        case .WANDER;       update(cast(*Behavior_Wander)behavior,      guy, dt);
        case .WANDER_FLOOR; update(cast(*Behavior_Wander_Floor)behavior,guy, dt);
        case .SPIN;         update(cast(*Behavior_Spin)behavior,        guy, dt);
        case .DEBUG;        update(cast(*Behavior_Debug)behavior,       guy, dt);
    }
}

reset :: (behavior: *Behavior) {
    VARIANCE :: 0.2; // Up to twenty percent above or below the stated boredom value.
    behavior.boredom = behavior.default_boredom + random(-VARIANCE, VARIANCE);

    behavior.time = 0.0;
    reset(*behavior.animation);

    if behavior.kind == {
        case .SLEEP;        reset(cast(*Behavior_Sleep)behavior);
        case .SHOCK;        reset(cast(*Behavior_Shock)behavior);
        case .HEART;        reset(cast(*Behavior_Heart)behavior);
        case .IDLE;         reset(cast(*Behavior_Idle)behavior);
        case .WANDER;       reset(cast(*Behavior_Wander)behavior);
        case .WANDER_FLOOR; reset(cast(*Behavior_Wander_Floor)behavior);
        case .SPIN;         reset(cast(*Behavior_Spin)behavior);
        case .DEBUG;        reset(cast(*Behavior_Debug)behavior);
    }
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Sleep :: struct {
    using behavior: Behavior;
    kind = .SLEEP;
}

reset :: (behavior: *Behavior_Sleep) {
}

update :: (behavior: *Behavior_Sleep, guy: *Guy, dt: float) {
    guy.velocity = .{};

    guy.animation = *behavior.animation;
    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Shock :: struct {
    using behavior: Behavior;
    kind = .SHOCK;
}

reset :: (behavior: *Behavior_Shock) {
}

update :: (behavior: *Behavior_Shock, guy: *Guy, dt: float) {
    guy.velocity = .{};

    guy.animation = *behavior.animation;
    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Heart :: struct {
    using behavior: Behavior;
    kind = .HEART;
}

reset :: (behavior: *Behavior_Heart) {
}

update :: (behavior: *Behavior_Heart, guy: *Guy, dt: float) {
    guy.velocity = .{};

    guy.animation = *behavior.animation;
    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Idle :: struct {
    using behavior: Behavior;
    kind = .IDLE;
}

reset :: (behavior: *Behavior_Idle) {
}

update :: (behavior: *Behavior_Idle, guy: *Guy, dt: float) {
    guy.velocity = .{};

    guy.animation = *behavior.animation;
    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Debug :: struct {
    using behavior: Behavior;
    kind = .DEBUG;

    initial_direction :: Vector2.{1, 1};

    // State
    direction : Vector2;
}

reset :: (behavior: *Behavior_Debug) {
}

update :: (behavior: *Behavior_Debug, guy: *Guy, dt: float) {
    if behavior.direction == Vector2.{} then behavior.direction = behavior.initial_direction;

    guy.velocity = normalize(behavior.direction) * guy.speed;

    guy.animation = *behavior.animation;
    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Wander :: struct {
    using behavior: Behavior;
    kind = .WANDER;

    period : float = 2.0;

    idle_animation : Sprite_Animation;

    // State
    time_this_direction: float; @NoSerialize
    wants_to_move_this_direction: Vector2; @NoSerialize
}

reset :: (behavior: *Behavior_Wander) {
    reset(*behavior.idle_animation);
    behavior.time_this_direction = 0.0;
    behavior.wants_to_move_this_direction = .{};
}

update :: (behavior: *Behavior_Wander, guy: *Guy, dt: float) {
    behavior.time_this_direction += dt;

    if behavior.time_this_direction > behavior.period {
        behavior.time_this_direction = 0.0;
        if random_get_zero_to_one() >= 0.5 {
            behavior.wants_to_move_this_direction = get_random_direction_vector_on_unit_circle();
        }
        else {
            behavior.wants_to_move_this_direction = .{};
        }

        guy.velocity = normalize(behavior.wants_to_move_this_direction) * guy.speed;
    }

    if behavior.wants_to_move_this_direction == .{} {
        guy.animation = *behavior.idle_animation;
    }
    else {
        guy.animation = *behavior.animation;
    }

    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Wander_Floor :: struct {
    using behavior: Behavior;
    kind = .WANDER_FLOOR;

    period : float = 2.0;

    idle_animation : Sprite_Animation;

    // State
    time_this_direction: float; @NoSerialize
    wants_to_move_this_direction: Vector2; @NoSerialize
}

reset :: (behavior: *Behavior_Wander_Floor) {
    reset(*behavior.idle_animation);
    behavior.time_this_direction = 0.0;
    behavior.wants_to_move_this_direction = .{};
}

update :: (behavior: *Behavior_Wander_Floor, guy: *Guy, dt: float) {
    behavior.time_this_direction += dt;

    if behavior.time_this_direction > behavior.period {
        behavior.time_this_direction = 0.0;
        if random_get_zero_to_one() >= 0.5 {
            // Left or right
            if random_get_zero_to_one() >= 0.5 {
                behavior.wants_to_move_this_direction = .{1, 0};
            }
            else {
                behavior.wants_to_move_this_direction = .{-1, 0};
            }
        }
        else {
            behavior.wants_to_move_this_direction = .{};
        }

        guy.velocity = normalize(behavior.wants_to_move_this_direction) * guy.speed;
    }

    if behavior.wants_to_move_this_direction == .{} {
        guy.animation = *behavior.idle_animation;
    }
    else {
        guy.animation = *behavior.animation;
    }

    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Spin :: struct {
    using behavior: Behavior;
    kind = .SPIN;

    period : float = 2.0;

    // State
    time_this_direction: float; @NoSerialize
    wants_to_move_this_direction: Vector2; @NoSerialize
}

reset :: (behavior: *Behavior_Spin) {
    behavior.time_this_direction = 0.0;
    behavior.wants_to_move_this_direction = .{};
}

update :: (behavior: *Behavior_Spin, guy: *Guy, dt: float) {
    behavior.time_this_direction += dt;

    if behavior.wants_to_move_this_direction == .{} then behavior.wants_to_move_this_direction = .{1, 0};

    if behavior.time_this_direction > behavior.period {
        behavior.time_this_direction = 0.0;
        behavior.wants_to_move_this_direction = -behavior.wants_to_move_this_direction;

        guy.velocity = normalize(behavior.wants_to_move_this_direction) * guy.speed;
    }

    guy.animation = *behavior.animation;
    update(guy.animation, dt);
}
