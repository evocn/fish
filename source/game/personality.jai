// Dayne
// Personality
// September 2024

// A Personality is a collection of Behaviors.
// It describes the possible actions for a fish to take in neutral,
// as well as how likely the fish is to start or get bored of actions.

Personality :: struct {
    current_whim : *Behavior;

    neutral_behaviors : [..] *Behavior;

    sleep_behavior : Behavior_Sleep;
    shock_behavior : Behavior_Shock;
    heart_behavior : Behavior_Heart;
    eat_behavior   : Behavior_Eat;

    schedule : Schedule;
}

update :: (using personality: *Personality, guy: *Guy, dt: float) {
    if !current_whim {
        next_whim := whats_next(guy);
        change_to_behavior(guy, next_whim);
    }

    // Update the current whim
    update(current_whim, guy, dt);

    // Potentially get bored
    if check_boredom(current_whim) {
        current_whim.done = true;
    }

    // Change behaviors
    if current_whim.done {
        next_whim := whats_next(guy);
        change_to_behavior(guy, next_whim);
    }
}

change_to_behavior :: (guy: *Guy, next: *Behavior) {
    guy.personality.current_whim = next;
    guy.velocity = .{};
    start(next);
}

check_boredom :: (behavior: *Behavior) -> bool {
    if behavior.time > behavior.boredom {
        return true;
    }

    return false;
}

// Performs a more advanced, tweakable query which accomodates:
// - Plans from the Schedule
// - Neutral Behaviors
// - Eventually, circumstances, events, locations, interactions, etc.
whats_next :: (guy: *Guy) -> behavior: *Behavior {
    using guy.personality;

    if #complete get_current_plan(schedule) == {
        case .NEUTRAL;  return xx random_choice(neutral_behaviors);
        case .SLEEP;    return xx *sleep_behavior;
        case .EAT;      return xx *eat_behavior;
    }
}
