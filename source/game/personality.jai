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
}

update :: (using personality: *Personality, guy: *Guy, dt: float) {
    if !current_whim {
        current_whim = random_choice(neutral_behaviors);
    }

    // Update the current whim
    update(current_whim, guy, dt);

    // Potentially get bored
    if check_boredom(current_whim) {
        current_whim = random_choice(neutral_behaviors);
        reset(current_whim);
    }
}

check_boredom :: (behavior: *Behavior) -> bool {
    if behavior.time > behavior.boredom {
        return true;
    }

    return false;
}

