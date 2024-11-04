// Dayne
// Behavior
// September 2024

// A Behavior is an AI controller for an entity. It tells an entity what to do at a given time.

Behavior :: struct {
    Kind :: enum {
        SLEEP;
        SHOCK;
        HEART;
        EAT;

        IDLE;
        SWIM;
        SWIM_UPWARD;
        WANDER;
        WANDER_FLOOR;

        BOUNCE;
        SPIN;

        DEBUG;
    }
    kind : Kind;

    animation : Sprite_Animation;

    swimming : bool;
    bouncy : bool;

    // @TODO: Should these choice-level variables be kept in the Personality? Or in the individual behaviors?
    default_boredom := 7.0;
    boredom : float;
    excitement_factor := 1;

    // State
    time : float; @NoSerialize
    done : bool; @NoSerialize
}

update :: (behavior: *Behavior, guy: *Guy, dt: float) {
    behavior.time += dt;
    if #complete behavior.kind == {
        case .SLEEP;        update(cast(*Behavior_Sleep)behavior,       guy, dt);
        case .SHOCK;        update(cast(*Behavior_Shock)behavior,       guy, dt);
        case .HEART;        update(cast(*Behavior_Heart)behavior,       guy, dt);
        case .EAT;          update(cast(*Behavior_Eat)behavior,         guy, dt);
        case .IDLE;         update(cast(*Behavior_Idle)behavior,        guy, dt);
        case .SWIM;         update(cast(*Behavior_Swim)behavior,        guy, dt);
        case .SWIM_UPWARD;  update(cast(*Behavior_Swim_Upward)behavior, guy, dt);
        case .WANDER;       update(cast(*Behavior_Wander)behavior,      guy, dt);
        case .WANDER_FLOOR; update(cast(*Behavior_Wander_Floor)behavior,guy, dt);
        case .BOUNCE;       update(cast(*Behavior_Bounce)behavior,      guy, dt);
        case .SPIN;         update(cast(*Behavior_Spin)behavior,        guy, dt);
        case .DEBUG;        update(cast(*Behavior_Debug)behavior,       guy, dt);
    }
}

start :: (behavior: *Behavior) {
    behavior.done = false;

    VARIANCE :: 0.2; // Up to twenty percent above or below the stated boredom value.
    behavior.boredom = behavior.default_boredom + random(-VARIANCE, VARIANCE);

    behavior.time = 0.0;
    reset(*behavior.animation);

    if #complete behavior.kind == {
        case .SLEEP;        start(cast(*Behavior_Sleep)behavior);
        case .SHOCK;        start(cast(*Behavior_Shock)behavior);
        case .HEART;        start(cast(*Behavior_Heart)behavior);
        case .EAT;          start(cast(*Behavior_Eat)behavior);
        case .IDLE;         start(cast(*Behavior_Idle)behavior);
        case .SWIM;         start(cast(*Behavior_Swim)behavior);
        case .SWIM_UPWARD;  start(cast(*Behavior_Swim_Upward)behavior);
        case .WANDER;       start(cast(*Behavior_Wander)behavior);
        case .WANDER_FLOOR; start(cast(*Behavior_Wander_Floor)behavior);
        case .BOUNCE;       start(cast(*Behavior_Bounce)behavior);
        case .SPIN;         start(cast(*Behavior_Spin)behavior);
        case .DEBUG;        start(cast(*Behavior_Debug)behavior);
    }
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Sleep :: struct {
    using behavior: Behavior;
    kind = .SLEEP;
}

start :: (behavior: *Behavior_Sleep) {
}

update :: (behavior: *Behavior_Sleep, guy: *Guy, dt: float) {
    guy.animation = *behavior.animation;
    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Shock :: struct {
    using behavior: Behavior;
    kind = .SHOCK;
}

start :: (behavior: *Behavior_Shock) {
}

update :: (behavior: *Behavior_Shock, guy: *Guy, dt: float) {
    guy.animation = *behavior.animation;
    behavior.done = update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Heart :: struct {
    using behavior: Behavior;
    kind = .HEART;
}

start :: (behavior: *Behavior_Heart) {
}

update :: (behavior: *Behavior_Heart, guy: *Guy, dt: float) {
    guy.animation = *behavior.animation;
    behavior.done = update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Eat :: struct {
    using behavior: Behavior;
    kind = .EAT;
}

start :: (behavior: *Behavior_Eat) {
}

update :: (behavior: *Behavior_Eat, guy: *Guy, dt: float) {
    guy.animation = *behavior.animation;
    behavior.done = update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Idle :: struct {
    using behavior: Behavior;
    kind = .IDLE;
}

start :: (behavior: *Behavior_Idle) {
}

update :: (behavior: *Behavior_Idle, guy: *Guy, dt: float) {
    guy.animation = *behavior.animation;
    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Debug :: struct {
    using behavior: Behavior;
    kind = .DEBUG;

    speed   : float = 10.0;

    initial_direction :: Vector2.{1, 1};

    // State
    direction : Vector2;
}

start :: (behavior: *Behavior_Debug) {
}

update :: (behavior: *Behavior_Debug, guy: *Guy, dt: float) {
    if behavior.direction == Vector2.{} then behavior.direction = behavior.initial_direction;

    guy.velocity = normalize(behavior.direction) * behavior.speed;

    guy.animation = *behavior.animation;
    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Bounce :: struct {
    using behavior: Behavior;
    kind = .BOUNCE;

    starting_direction : Vector2;

    speed   : float = 22.0;
}

start :: (behavior: *Behavior_Bounce) {
    diagonals := Vector2.[.{1, 1}, .{1, -1}, .{-1, 1}, .{-1, -1}];

    behavior.starting_direction = random_choice(diagonals);
}

update :: (behavior: *Behavior_Bounce, guy: *Guy, dt: float) {
    if guy.velocity == .{} then guy.velocity = behavior.starting_direction * behavior.speed;

    guy.animation = *behavior.animation;
    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Swim :: struct {
    using behavior: Behavior;
    kind = .SWIM;

    speed   : float = 8;

    period  : float = 2.0;

    // State
    time_this_direction: float; @NoSerialize
    wants_to_move_this_direction: Vector2; @NoSerialize
}

start :: (behavior: *Behavior_Swim) {
    behavior.time_this_direction = 0.0;
    behavior.wants_to_move_this_direction = .{};
}

update :: (behavior: *Behavior_Swim, guy: *Guy, dt: float) {
    behavior.time_this_direction += dt;

    if behavior.time_this_direction > behavior.period {
        behavior.time_this_direction = 0.0;
        behavior.wants_to_move_this_direction = get_random_direction_vector_on_unit_circle();

        guy.velocity = normalize(behavior.wants_to_move_this_direction) * behavior.speed;
    }

    guy.animation = *behavior.animation;

    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Swim_Upward :: struct {
    using behavior: Behavior;
    kind = .SWIM_UPWARD;

    speed   : float = 8;

    period  : float = 2.0;

    // State
    time_this_direction: float; @NoSerialize
    wants_to_move_this_direction: Vector2; @NoSerialize
}

start :: (behavior: *Behavior_Swim_Upward) {
    behavior.time_this_direction = 0.0;
    behavior.wants_to_move_this_direction = .{};
}

update :: (behavior: *Behavior_Swim_Upward, guy: *Guy, dt: float) {
    behavior.time_this_direction += dt;

    if behavior.time_this_direction > behavior.period {
        behavior.time_this_direction = 0.0;
        while behavior.wants_to_move_this_direction.y < 0 {
            behavior.wants_to_move_this_direction = get_random_direction_vector_on_unit_circle();
        }

        guy.velocity = normalize(behavior.wants_to_move_this_direction) * behavior.speed;
    }

    guy.animation = *behavior.animation;

    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Wander :: struct {
    using behavior: Behavior;
    kind = .WANDER;

    speed   : float = 5;

    period  : float = 2.0;

    idle_animation : Sprite_Animation;

    // State
    time_this_direction: float; @NoSerialize
    wants_to_move_this_direction: Vector2; @NoSerialize
}

start :: (behavior: *Behavior_Wander) {
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

        guy.velocity = normalize(behavior.wants_to_move_this_direction) * behavior.speed;
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

    speed   : float = 6;

    period  : float = 2.0;

    idle_animation : Sprite_Animation;

    // State
    time_this_direction: float; @NoSerialize
    wants_to_move_this_direction: Vector2; @NoSerialize
}

start :: (behavior: *Behavior_Wander_Floor) {
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

        guy.velocity = normalize(behavior.wants_to_move_this_direction) * behavior.speed;
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

    speed   : float = 20;

    period  : float = 2.0;

    // State
    time_this_direction: float; @NoSerialize
    wants_to_move_this_direction: Vector2; @NoSerialize
}

start :: (behavior: *Behavior_Spin) {
    behavior.time_this_direction = 0.0;
    behavior.wants_to_move_this_direction = .{};
}

update :: (behavior: *Behavior_Spin, guy: *Guy, dt: float) {
    behavior.time_this_direction += dt;

    if behavior.wants_to_move_this_direction == .{} then behavior.wants_to_move_this_direction = .{1, 0};

    if behavior.time_this_direction > behavior.period {
        behavior.time_this_direction = 0.0;
        behavior.wants_to_move_this_direction = -behavior.wants_to_move_this_direction;

        guy.velocity = normalize(behavior.wants_to_move_this_direction) * behavior.speed;
    }

    guy.animation = *behavior.animation;
    update(guy.animation, dt);
}
