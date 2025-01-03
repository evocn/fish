// Dayne
// Behavior
// September 2024

// A Behavior is an AI controller for an entity. It tells an entity what to do at a given time.

Behavior :: struct {
    Kind :: enum {
        ONE_SHOT;
        SLEEP;
        EAT;

        IDLE;
        SWIM;
        SWIM_UPWARD;
        WANDER;
        WANDER_FLOOR;
        BOUNCE;
        SPIN;
        JUMP;
        FORWARD;

        EIGHT_WAY;

        DEBUG;
    }
    kind : Kind;

    animation : Sprite_Animation;

    swimming : bool;
    bouncy_x : bool;
    bouncy_y : bool;

    // Governing choice
    minimum_duration : float;
    likelihood : float;

    // State
    time : float; @NoSerialize
    done : bool; @NoSerialize
}

update :: (behavior: *Behavior, guy: *Guy, dt: float) {
    behavior.time += dt;
    if #complete behavior.kind == {
        case .ONE_SHOT;     update(cast(*Behavior_One_Shot)behavior,    guy, dt);
        case .SLEEP;        update(cast(*Behavior_Sleep)behavior,       guy, dt);
        case .EAT;          update(cast(*Behavior_Eat)behavior,         guy, dt);
        case .IDLE;         update(cast(*Behavior_Idle)behavior,        guy, dt);
        case .SWIM;         update(cast(*Behavior_Swim)behavior,        guy, dt);
        case .SWIM_UPWARD;  update(cast(*Behavior_Swim_Upward)behavior, guy, dt);
        case .WANDER;       update(cast(*Behavior_Wander)behavior,      guy, dt);
        case .WANDER_FLOOR; update(cast(*Behavior_Wander_Floor)behavior,guy, dt);
        case .BOUNCE;       update(cast(*Behavior_Bounce)behavior,      guy, dt);
        case .SPIN;         update(cast(*Behavior_Spin)behavior,        guy, dt);
        case .JUMP;         update(cast(*Behavior_Jump)behavior,        guy, dt);
        case .FORWARD;      update(cast(*Behavior_Forward)behavior,     guy, dt);
        case .EIGHT_WAY;    update(cast(*Behavior_Eight_Way)behavior,   guy, dt);
        case .DEBUG;        update(cast(*Behavior_Debug)behavior,       guy, dt);
    }
}

start :: (behavior: *Behavior) {
    behavior.done = false;

    behavior.time = 0.0;
    reset(*behavior.animation);

    if #complete behavior.kind == {
        case .ONE_SHOT;     start(cast(*Behavior_One_Shot)behavior);
        case .SLEEP;        start(cast(*Behavior_Sleep)behavior);
        case .EAT;          start(cast(*Behavior_Eat)behavior);
        case .IDLE;         start(cast(*Behavior_Idle)behavior);
        case .SWIM;         start(cast(*Behavior_Swim)behavior);
        case .SWIM_UPWARD;  start(cast(*Behavior_Swim_Upward)behavior);
        case .WANDER;       start(cast(*Behavior_Wander)behavior);
        case .WANDER_FLOOR; start(cast(*Behavior_Wander_Floor)behavior);
        case .BOUNCE;       start(cast(*Behavior_Bounce)behavior);
        case .SPIN;         start(cast(*Behavior_Spin)behavior);
        case .JUMP;         start(cast(*Behavior_Jump)behavior);
        case .FORWARD;      start(cast(*Behavior_Forward)behavior);
        case .EIGHT_WAY;    start(cast(*Behavior_Eight_Way)behavior);
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

Behavior_One_Shot :: struct {
    using behavior: Behavior;
    kind = .ONE_SHOT;

    sfx : string;
}

start :: (behavior: *Behavior_One_Shot) {
    if behavior.sfx != "" then play_sfx(behavior.sfx);
}

update :: (behavior: *Behavior_One_Shot, guy: *Guy, dt: float) {
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

    speed   : float = 50.0;
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

    down_animation: Sprite_Animation;

    speed   : float = 8;

    period  : float = 2.0;

    // State
    time_this_direction: float; @NoSerialize
    wants_to_move_this_direction: Vector2; @NoSerialize
}

start :: (behavior: *Behavior_Swim) {
    behavior.time_this_direction = 20.0;
}

update :: (behavior: *Behavior_Swim, guy: *Guy, dt: float) {
    behavior.time_this_direction += dt;

    if behavior.time_this_direction > behavior.period {
        behavior.time_this_direction = 0.0;
        behavior.wants_to_move_this_direction = get_random_direction_vector_on_unit_circle();

        guy.velocity = normalize(behavior.wants_to_move_this_direction) * behavior.speed;
    }

    if guy.velocity.y > 0 {
        guy.animation = *behavior.animation;
    }
    else {
        guy.animation = *behavior.down_animation;
    }

    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Swim_Upward :: struct {
    using behavior: Behavior;
    kind = .SWIM_UPWARD;

    speed   : float;

    period  : float = 1.0;

    // State
    time_this_direction: float; @NoSerialize
    wants_to_move_this_direction: Vector2; @NoSerialize
}

start :: (behavior: *Behavior_Swim_Upward) {
    behavior.time_this_direction = 20.0;
}

update :: (behavior: *Behavior_Swim_Upward, guy: *Guy, dt: float) {
    behavior.time_this_direction += dt;

    if behavior.time_this_direction > behavior.period {
        behavior.time_this_direction = 0.0;
        behavior.wants_to_move_this_direction = get_random_upward_direction_vectory_on_unit_circle();

        guy.velocity = normalize(behavior.wants_to_move_this_direction) * behavior.speed;
    }

    // Make him kind of slow down inbetween strokes
    guy.velocity.y -= 0.02;
    guy.velocity.y = max(guy.velocity.y, 0);

    guy.animation = *behavior.animation;

    if guy.y >= game.level.pixel_extents.height - 16 then behavior.done = true;

    animation_cycle_done := update(guy.animation, dt);
    if animation_cycle_done then play_sfx("swim", volume = 0.5);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Wander :: struct {
    using behavior: Behavior;
    kind = .WANDER;

    speed   : float = 5;

    period  : float = 1.0;

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

        guy.velocity.x = (normalize(behavior.wants_to_move_this_direction) * behavior.speed).x;
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

        guy.velocity.x = (normalize(behavior.wants_to_move_this_direction) * behavior.speed).x;
    }

    guy.animation = *behavior.animation;
    update(guy.animation, dt);
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Jump :: struct {
    using behavior: Behavior;
    kind = .JUMP;

    charge_animation : Sprite_Animation;
    flight_animation : Sprite_Animation;
    land_animation : Sprite_Animation;

    speed : float;

    charge_time : float;

    // State
    state : enum {
        CHARGE;
        LEAP;
        FLY;
        LAND;
    }

    jumping_right : bool;
}

start :: (behavior: *Behavior_Jump) {
    behavior.state = .CHARGE;

    reset(*behavior.charge_animation);
    reset(*behavior.flight_animation);
    reset(*behavior.land_animation);

    behavior.jumping_right = coin_flip();
}

update :: (behavior: *Behavior_Jump, guy: *Guy, dt: float) {
    if behavior.state == {
        case .CHARGE;
            guy.velocity.x = 0;

            guy.animation = *behavior.charge_animation;
            update(guy.animation, dt);

            if !check_if_grounded(*guy.actor) {
                behavior.done = true;
                return;
            }

            if behavior.time > behavior.charge_time {
                random_vertical_velocity := random(70, 100);
                guy.velocity.y = random_vertical_velocity;

                random_horizontal_velocity := random(5, 30);
                if behavior.jumping_right then guy.velocity.x = random_horizontal_velocity;
                                          else guy.velocity.x = -1 * random_horizontal_velocity;
                behavior.state = .LEAP;

                play_sfx("jump");
            }

        case .LEAP;
            guy.animation = *behavior.animation;
            animation_done := update(guy.animation, dt);
            if animation_done {
                behavior.state = .FLY;

                guy.animation = *behavior.flight_animation;
                reset(*behavior.flight_animation);
                update(guy.animation, 0);
            }

        case .FLY;
            guy.animation = *behavior.flight_animation;
            update(guy.animation, dt);

            if check_if_grounded(*guy.actor) then behavior.state = .LAND;

        case .LAND;
            guy.velocity.x = 0;

            guy.animation = *behavior.land_animation;
            animation_done := update(guy.animation, dt);
            if animation_done {
                behavior.done = true;

                guy.animation = *behavior.charge_animation;
                reset(*behavior.charge_animation);
                update(guy.animation, 0);
            }
    }
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Eight_Way :: struct {
    using behavior: Behavior;
    kind = .EIGHT_WAY;

    diagonal_animation : Sprite_Animation;

    speed   : float = 20.0;
    period  : float = 5.0;

    // State
    time_this_direction: float; @NoSerialize
    wants_to_move_this_direction: Vector2; @NoSerialize
}

start :: (behavior: *Behavior_Eight_Way) {
    behavior.time_this_direction = 20.0;
}

update :: (behavior: *Behavior_Eight_Way, guy: *Guy, dt: float) {
    behavior.time_this_direction += dt;

    if behavior.time_this_direction > behavior.period {
        behavior.time_this_direction = 0.0;
        behavior.wants_to_move_this_direction = get_random_direction_vector_on_unit_circle();

        vertical := behavior.wants_to_move_this_direction.x < 0.3 && behavior.wants_to_move_this_direction.x > -0.3;
        if vertical then guy.animation = *behavior.animation;
        else guy.animation = *behavior.diagonal_animation;

        guy.velocity = normalize(behavior.wants_to_move_this_direction) * behavior.speed;
    }

    slowdown_factor := 1.0 / behavior.period;
    {
        {
            positive := guy.velocity.x >= 0;
            if positive then guy.velocity.x -= guy.velocity.x * slowdown_factor * dt;
                        else guy.velocity.x += guy.velocity.x * slowdown_factor * dt;
        }

        {
            positive := guy.velocity.y >= 0;
            if positive then guy.velocity.y -= guy.velocity.y * slowdown_factor * dt;
                        else guy.velocity.y += guy.velocity.y * slowdown_factor * dt;
        }
    }

    update(guy.animation, dt);
}

get_random_direction_for_eight_way_swimming :: () -> Vector2 {
    diagonals := Vector2.[.{1, 1}, .{1, -1}, .{-1, 1}, .{-1, -1}];
    cardinals := Vector2.[.{1, 0}, .{0, 1}, .{-1, 0}, .{0, -1}];

    direction : Vector2;
    if random() < 0.5 then direction = random_choice(diagonals);
    else direction = random_choice(cardinals);

    return direction;
}

////////////////////////////////////////////////////////////////////////////////

Behavior_Forward :: struct {
    using behavior: Behavior;
    kind = .FORWARD;

    speed   : float = 20;
}

start :: (behavior: *Behavior_Forward) {
}

update :: (behavior: *Behavior_Forward, guy: *Guy, dt: float) {
    if guy.velocity.x == 0 then guy.velocity.x = behavior.speed;

    guy.animation = *behavior.animation;
    update(guy.animation, dt);
}
