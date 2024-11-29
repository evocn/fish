// Dayne
// Game
// August 2024

#load "level.jai";

#load "entity.jai";
//#load "entity_serialization.jai";
#load "tile.jai";

#load "personality.jai";
#load "behavior.jai";
#load "schedule.jai";

#load "sprite_animation.jai";

#load "entities/test.jai";
#load "entities/guy.jai";
#load "entities/particle_system.jai";
#load "entities/toy.jai";
#load "entities/food.jai";

#load "collisions/simulation.jai";

#load "interaction.jai";

Game :: struct {
    using constants : struct {
        GRAVITY :: -50.0;
    }

    using data : struct {
        guys : [..] *Guy;
    }

    player : Player_Interface;

    level : Level;
    entities : [..] *Entity;

    cursor : struct {
        state : Cursor_State;
    }

    simulation: Simulation;

    camera: Pair;
    camera_zoom : int;

    focused_guy: *Guy;

    using internals : struct {
        arena : Flat_Pool;
    }
}


simulate :: (using game: *Game, dt: float) {
    {
        using player.input;

        if      up.is_held      cursor.state = .PET;
        else if left.is_held    cursor.state = .SNAP;
        else if right.is_held   cursor.state = .SLEEP;
        else                    cursor.state = .NEUTRAL;
    }

    for entity : entities {
        update(entity, dt);
    }

    if focused_guy {
        camera_zoom = 2;

        running_camera : Pair;
        {
            running_camera = .{focused_guy.x, focused_guy.y}; // guy in bottom left.
            running_camera += .{xx (-1 * 1.4 * TILE_SIZE_IN_PIXELS), -1 * 1 * TILE_SIZE_IN_PIXELS}; // center them in the middle left of the screen

            clamp(running_camera.x, 0, 1000);
        }
        camera = running_camera;
    }
    else {
        camera = .{};
        camera_zoom = 1;
    }

    rainbow_color = update_rainbow_color(dt);
}


initialize :: (game: *Game) {
    load_level_from_file(*game.level, "1");

    game.camera = .{};
    game.camera_zoom = 1;

    // Entities
    {
        particle_system : *Particle_System = xx new_entity(.PARTICLE_SYSTEM);
        {
            using particle_system;
        }
        array_add(*game.entities, xx particle_system);

        toy : *Toy = xx new_entity(.TOY);
        {
            using toy;

            name = "anchor";

            x = 128;
            y = 16;
            width  = 32;
            height = 32;

            animation = make_animation("Anchor");
        }
        array_add(*game.entities, xx toy);

        kelp : *Toy = xx new_entity(.TOY);
        {
            using kelp;

            name = "kelp";

            x = 32;
            y = 16;
            width  = 16;
            height = 16;

            animation = make_animation("Kelp");
        }
        array_add(*game.entities, xx kelp);

        food : *Food = xx new_entity(.FOOD);
        {
            using food;

            x = 40;
            y = 112;
        }
        array_add(*game.entities, xx food);

        // Load Guys

        frog : *Guy = xx new_entity(.GUY);
        {
            using frog;

            name = "frog";

            rarity = .COMMON;

            x = 100;
            y = 16;
            width  = 14;
            height = 14;

            {
                using personality;

                idle := make_animation("Frog-Idle",     speed = 5.0);
                walk := make_animation("Frog-Walk",     speed = 7.0);
                sleep := make_animation("Frog-Sleep",   speed = 10.0);
                shock := make_animation("Frog-Shock",   speed = 12.0);
                heart := make_animation("Frog-Heart",   speed = 10.0);
                swim := make_animation("Frog-Swim",     speed = 6.0);

                charge := make_animation("Frog-Charge");
                jump := make_animation("Frog-Jump",     speed = 30.0);
                fly := make_animation("Frog-Fly");
                land := make_animation("Frog-Land",     speed = 50.0);

                animation = idle;


                {
                    b := New(Behavior_Idle);
                    b.animation = idle;

                    b.minimum_duration = 5;
                    b.likelihood = 0.2;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Wander_Floor);
                    b.animation = walk;
                    b.idle_animation = idle;

                    b.bouncy_x = true;

                    b.minimum_duration = 8;
                    b.likelihood = 0.3;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Swim_Upward);
                    b.animation = swim;

                    b.speed = 25.0;

                    b.swimming = true;
                    b.bouncy_x = true;
                    b.bouncy_y = false;

                    b.minimum_duration = 10;
                    b.likelihood = 0.1;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Jump);
                    b.animation = jump;
                    b.charge_animation = charge;
                    b.flight_animation = fly;
                    b.land_animation = land;

                    b.charge_time = 1.0;

                    b.swimming = false;
                    b.bouncy_x = true;
                    b.bouncy_y = false;

                    b.likelihood = 0.4;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    sleep_behavior = xx New(Behavior_Sleep);
                    using sleep_behavior;
                    animation = sleep;
                }

                {
                    shock_behavior = xx New(Behavior_One_Shot);
                    using shock_behavior;
                    animation = shock;
                }

                {
                    heart_behavior = xx New(Behavior_One_Shot);
                    using heart_behavior;
                    animation = heart;
                }

                {
                    eat_behavior = xx New(Behavior_Eat);
                    using eat_behavior;
                    animation = idle;
                }

                {
                    schedule.hours = Plan.[
                        .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .NEUTRAL, .NEUTRAL,
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL,
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .SLEEP,
                    ];
                }
            }

            {
                using biography;

                array_add(*facts, "6 years old");
                array_add(*facts, "has over 10,000 children");
                array_add(*facts, "");
                array_add(*facts, "favorite food: fleas");

                quote = "ribbit";

                color = green;
            }
        }

        tako : *Guy = xx new_entity(.GUY);
        {
            using tako;

            name = "tako";

            rarity = .MYTHIC;

            x = 32;
            y = 16;
            width  = 15;
            height = 15;

            {
                using personality;

                idle := make_animation("Tako-Idle",     speed = 10.0);
                walk := make_animation("Tako-Walk",     speed = 10.0);
                sleep := make_animation("Tako-Sleep",   speed = 10.0);
                shock := make_animation("Tako-Shock",   speed = 15.0);
                heart := make_animation("Tako-Heart",   speed = 8.0);

                animation = idle;


                {
                    b := New(Behavior_Idle);
                    b.animation = idle;

                    b.minimum_duration = 5;
                    b.likelihood = 0.5;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Wander_Floor);
                    b.animation = walk;
                    b.idle_animation = idle;

                    b.bouncy_x = true;

                    b.minimum_duration = 15;
                    b.likelihood = 0.5;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    sleep_behavior = xx New(Behavior_Sleep);
                    using sleep_behavior;
                    animation = sleep;
                }

                {
                    shock_behavior = xx New(Behavior_One_Shot);
                    using shock_behavior;
                    animation = shock;
                }

                {
                    heart_behavior = xx New(Behavior_One_Shot);
                    using heart_behavior;
                    animation = heart;
                }

                {
                    eat_behavior = xx New(Behavior_Eat);
                    using eat_behavior;
                    animation = idle;
                }

                {
                    schedule.hours = Plan.[
                        .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP,
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .SLEEP, .NEUTRAL,
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL,
                    ];
                }
            }

            {
                using biography;

                array_add(*facts, "professional chef");
                array_add(*facts, "favorite food: souffle");
                array_add(*facts, "");
                array_add(*facts, "least favorite: peas");

                quote = "your order?";

                color = red;
            }
        }

        clam : *Guy = xx new_entity(.GUY);
        {
            using clam;

            name = "clam";

            rarity = .RARE;

            x = 162;
            y = 80;
            width  = 12;
            height = 6;

            {
                using personality;

                idle := make_animation("Clam-Idle");
                sleep := make_animation("Clam-Sleep", speed = 2.0);
                shock := make_animation("Clam-Shock", speed = 12.0);
                heart := make_animation("Clam-Heart", speed = 10.0);

                animation = idle;


                {
                    b := New(Behavior_Idle);
                    b.animation = idle;

                    b.minimum_duration = 5;
                    b.likelihood = 1.0;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    sleep_behavior = xx New(Behavior_Sleep);
                    using sleep_behavior;
                    animation = sleep;
                }

                {
                    shock_behavior = xx New(Behavior_One_Shot);
                    using shock_behavior;
                    animation = shock;
                }

                {
                    heart_behavior = xx New(Behavior_One_Shot);
                    using heart_behavior;
                    animation = heart;
                }

                {
                    eat_behavior = xx New(Behavior_Eat);
                    using eat_behavior;
                    animation = idle;
                }

                {
                    schedule.hours = Plan.[
                        .NEUTRAL, .SLEEP, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL,
                        .NEUTRAL, .SLEEP, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL,
                        .NEUTRAL, .SLEEP, .NEUTRAL, .NEUTRAL, .SLEEP, .NEUTRAL, .NEUTRAL, .NEUTRAL,
                    ];
                }
            }

            {
                using biography;

                array_add(*facts, "a real homebody");
                array_add(*facts, "only comes out sometimes");
                array_add(*facts, "");
                array_add(*facts, "extremely happy");

                quote = "hi";

                color = white;
            }
        }

        jelly : *Guy = xx new_entity(.GUY);
        {
            using jelly;

            name = "jelly";

            rarity = .COMMON;

            x = 128;
            y = 16;
            width  = 16;
            height = 16;

            {
                using personality;

                idle := make_animation("Jelly-Idle",    speed = 7.0);
                walk := make_animation("Jelly-Walk",    speed = 10.0);
                sleep := make_animation("Jelly-Sleep",  speed = 10.0);
                shock := make_animation("Jelly-Shock",  speed = 20.0);
                heart := make_animation("Jelly-Heart",  speed = 10.0);

                animation = idle;


                {
                    b := New(Behavior_Idle);
                    b.animation = idle;

                    b.minimum_duration = 5;
                    b.likelihood = 0.5;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Wander_Floor);
                    b.animation = walk;
                    b.idle_animation = idle;

                    b.bouncy_x = true;

                    b.minimum_duration = 10;
                    b.likelihood = 0.5;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    sleep_behavior = xx New(Behavior_Sleep);
                    using sleep_behavior;
                    animation = sleep;
                }

                {
                    shock_behavior = xx New(Behavior_One_Shot);
                    using shock_behavior;
                    animation = shock;
                }

                {
                    heart_behavior = xx New(Behavior_One_Shot);
                    using heart_behavior;
                    animation = heart;
                }

                {
                    eat_behavior = xx New(Behavior_Eat);
                    using eat_behavior;
                    animation = idle;
                }

                {
                    schedule.hours = Plan.[
                        .SLEEP, .SLEEP, .SLEEP, .SLEEP, .NEUTRAL, .NEUTRAL, .NEUTRAL, .SLEEP,
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL,
                        .SLEEP, .NEUTRAL, .NEUTRAL, .NEUTRAL, .SLEEP, .NEUTRAL, .NEUTRAL, .NEUTRAL,
                    ];
                }
            }

            {
                using biography;

                array_add(*facts, "sticky");
                array_add(*facts, "don't get too close");

                quote = "zzt";

                color = teal;
            }
        }

        blowfish : *Guy = xx new_entity(.GUY);
        {
            using blowfish;

            name = "blowfish";

            rarity = .COMMON;

            x = 64;
            y = 64;
            width  = 14;
            height = 14;

            {
                using personality;

                idle := make_animation("Blowfish-Idle",     speed = 7.0);
                walk := make_animation("Blowfish-Walk",     speed = 10.0);
                bounce := make_animation("Blowfish-Bounce", speed = 10.0);
                heart := make_animation("Blowfish-Happy",   speed = 10.0);
                sleep := make_animation("Blowfish-Sleep",   speed = 10.0);
                //shock := make_animation("Blowfish-Shock");

                animation = idle;


                {
                    b := New(Behavior_Wander);
                    b.animation = walk;
                    b.idle_animation = idle;

                    b.speed = 15.0;

                    b.swimming = true;
                    b.bouncy_x = true;
                    b.bouncy_y = true;

                    b.minimum_duration = 5;
                    b.likelihood = 0.5;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Swim);
                    b.animation = walk;

                    b.speed = 25;

                    b.swimming = true;
                    b.bouncy_x = true;
                    b.bouncy_y = true;

                    b.minimum_duration = 10;
                    b.likelihood = 0.5;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Sleep);
                    b.animation = sleep;

                    b.swimming = true;

                    sleep_behavior = xx b;
                }

                {
                    b := New(Behavior_Bounce);
                    b.animation = bounce;

                    b.swimming = true;
                    b.bouncy_x = true;
                    b.bouncy_y = true;

                    b.minimum_duration = 3;

                    shock_behavior = xx b;
                }

                {
                    b := New(Behavior_One_Shot);
                    b.animation = heart;

                    heart_behavior = xx b;
                }

                {
                    b := New(Behavior_Eat);
                    b.animation = idle;

                    eat_behavior = xx b;
                }

                {
                    schedule.hours = Plan.[
                        .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .NEUTRAL,
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .SLEEP, .NEUTRAL, .NEUTRAL,
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .SLEEP, .NEUTRAL, .NEUTRAL, .NEUTRAL,
                    ];
                }
            }

            {
                using biography;

                array_add(*facts, "curious, but hesitant");
                array_add(*facts, "does not like surprises");
                array_add(*facts, "");
                array_add(*facts, "dreams of a trip someday");

                quote = "blub";

                color = yellow;
            }
        }

        blob : *Guy = xx new_entity(.GUY);
        {
            using blob;

            name = "blob";

            rarity = .RARE;

            x = 32;
            y = 96;
            width  = 16;
            height = 16;

            {
                using personality;

                idle := make_animation("Blobfish-Idle",         speed = 1.0);
                blink := make_animation("Blobfish-Blink",       speed = 10.0);
                yawn := make_animation("Blobfish-OpenMouth",    speed = 10.0);

                animation = idle;

                {
                    b := New(Behavior_Idle);
                    b.animation = idle;

                    b.minimum_duration = 5;
                    b.likelihood = 0.9;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_One_Shot);
                    b.animation = yawn;

                    b.likelihood = 0.05;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_One_Shot);
                    b.animation = blink;

                    b.likelihood = 0.05;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    sleep_behavior = xx New(Behavior_Sleep);
                    using sleep_behavior;
                    animation = idle;
                }

                {
                    shock_behavior = xx New(Behavior_One_Shot);
                    using shock_behavior;
                    animation = idle;
                }

                {
                    heart_behavior = xx New(Behavior_One_Shot);
                    using heart_behavior;
                    animation = idle;
                }

                {
                    eat_behavior = xx New(Behavior_Eat);
                    using eat_behavior;
                    animation = idle;
                }

                {
                    schedule.hours = Plan.[
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL,
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL,
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL,
                    ];
                }
            }

            {
                using biography;

                array_add(*facts, "???");

                quote = "?";

                color = pink;
            }
        }

        crab : *Guy = xx new_entity(.GUY);
        {
            using crab;

            name = "crab";

            rarity = .COMMON;

            x = 112;
            y = 16;
            width  = 12;
            height = 12;

            {
                using personality;

                idle := make_animation("Crab-Idle",     speed = 10.0);
                walk := make_animation("Crab-Walk",     speed = 10.0);
                heart := make_animation("Crab-Heart",   speed = 1.0);
                shock := make_animation("Crab-Shock",   speed = 1.0);
                sleep := make_animation("Crab-Sleep",   speed = 2.0);

                animation = idle;


                {
                    b := New(Behavior_Idle);
                    b.animation = idle;

                    b.minimum_duration = 3;
                    b.likelihood = 0.2;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Wander_Floor);
                    b.animation = walk;
                    b.idle_animation = idle;

                    b.minimum_duration = 10;
                    b.likelihood = 0.8;

                    b.speed = 25;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    sleep_behavior = xx New(Behavior_Sleep);
                    using sleep_behavior;
                    animation = sleep;
                }

                {
                    shock_behavior = xx New(Behavior_One_Shot);
                    using shock_behavior;
                    animation = shock;
                }

                {
                    heart_behavior = xx New(Behavior_One_Shot);
                    using heart_behavior;
                    animation = heart;
                }

                {
                    eat_behavior = xx New(Behavior_Eat);
                    using eat_behavior;
                    animation = idle;
                }

                {
                    schedule.hours = Plan.[
                        .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, 
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL,
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL,
                    ];
                }
            }

            {
                using biography;

                array_add(*facts, "Indestructible shell");

                quote = "sup";

                color = orange;
            }
        }

        // Add all the guys defined here to the list of guys who can be populated.
        {
            array_add(*game.guys, frog);
            array_add(*game.guys, tako);
            array_add(*game.guys, clam);
            array_add(*game.guys, jelly);
            array_add(*game.guys, blowfish);
            array_add(*game.guys, blob);
            array_add(*game.guys, crab);
        }

        // Validate some stuff about these guys
        {
            for guy : game.guys {
                // Neutral behavior likelihoods must add up to 1.
                {
                    total := 0.0;
                    for behavior : guy.personality.neutral_behaviors  total += behavior.likelihood;
                    assert(total == 1.0);
                }
            }
        }

        genocide(game);

        seed := generate_seed_from_date_and_hour();
        //populate(game, seed);
        populate_everyone(game);
    }
}

genocide :: (using game: *Game) {
    for entities if it.kind == .GUY then remove it;
}

populate_everyone :: (using game: *Game) {
    for guy : guys {
        array_add(*entities, xx guy);
        array_add(*simulation.actors, *guy.actor);
    }
}

populate :: (using game: *Game, seed: Random_State) {
    guys_in_the_tank : int;
    for guy : guys {
        roll := random_get_zero_to_one(*seed);
        if roll <= get_probability(guy.rarity) {
            array_add(*game.entities, xx guy);
            array_add(*game.simulation.actors, *guy.actor);
            guys_in_the_tank += 1;
        }
    }

    // Gotta have at least one...
    if guys_in_the_tank == 0 {
        guy := random_choice(guys, *seed);
        array_add(*game.entities, xx guy);
        array_add(*game.simulation.actors, *guy.actor);
        guys_in_the_tank += 1;
    }
}

// Seed the population generator with the hour and the date.
// This way, it doesn't feel like you're just rolling the dice every time you open the app.
generate_seed_from_date_and_hour :: () -> Random_State {
    random_state : Random_State;

    t := time();
    seed : u64 = cast(u64)t.hour + (cast(u64)t.day_of_week_starting_at_0 << 8);

    random_seed(*random_state, seed);

    return random_state;
}

generate_seed :: () -> Random_State {
    random_state : Random_State;

    t := time();

    seed : u64 = cast(u64)t.millisecond;

    random_seed(*random_state, seed);

    return random_state;
}
