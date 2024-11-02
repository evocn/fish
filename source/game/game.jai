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

#load "collisions/simulation.jai";

#load "interaction.jai";

Game :: struct {
    player : Player_Interface;

    level : Level;
    entities : [..] *Entity;

    cursor : struct {
        state : Cursor_State;
    }

    simulation: Simulation;

    camera: Pair;
}


simulate :: (game: *Game, dt: float) {
    for entity : game.entities {
        update(entity, dt);
    }

    game.camera = .{};

    {
        using game.player.input;

        if      up.is_held      game.cursor.state = .PET;
        else if left.is_held    game.cursor.state = .SNAP;
        else if right.is_held   game.cursor.state = .SLEEP;
        else                    game.cursor.state = .NEUTRAL;
    }

    rainbow_color = update_rainbow_color(dt);
}


initialize :: (game: *Game) {
    load_level_from_file(*game.level, "1");

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

            {
                animation = New(Sprite_Animation);
                {
                    using animation;
                    sheet = "anchor";
                    frame_count = 1;
                }
            }
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

            {
                animation = New(Sprite_Animation);
                {
                    using animation;
                    sheet = "kelp";
                    frame_count = 1;
                }
            }
        }
        array_add(*game.entities, xx kelp);

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

                idle := New(Sprite_Animation);
                {
                    using idle;
                    sheet = "Frog-Idle";
                    frame_count = 8;
                    speed = 5.0;
                }

                walk := Sprite_Animation.{
                    sheet = "Frog-Walk",
                    frame_count = 4,
                    speed = 7,
                };

                sleep := Sprite_Animation.{
                    sheet = "Frog-Sleep",
                    frame_count = 15,
                    speed = 10.0,
                };

                shock := Sprite_Animation.{
                    sheet = "Frog-Shock",
                    frame_count = 8,
                    speed = 12.0,
                };

                heart := Sprite_Animation.{
                    sheet = "Frog-Heart",
                    frame_count = 11,
                    speed = 10.0,
                };

                swim := Sprite_Animation.{
                    sheet = "Frog-Swim",
                    frame_count = 5,
                    speed = 8.0,
                };

                jump := Sprite_Animation.{
                    sheet = "Frog-Jump",
                    frame_count = 11,
                    speed = 10.0,
                };

                {
                    b := New(Behavior_Idle);
                    b.animation = idle;

                    b.default_boredom = 4;

                    start(b);
                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Wander_Floor);
                    b.animation = walk;
                    b.idle_animation = idle;

                    b.default_boredom = 30;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Swim);
                    b.animation = swim;

                    b.speed = 15.0;

                    b.swimming = true;

                    b.default_boredom = 20;

                    array_add(*neutral_behaviors, xx b);
                }

                sleep_behavior = Behavior_Sleep.{animation = sleep, default_boredom = 50};
                shock_behavior = Behavior_Shock.{animation = shock, default_boredom = 1};
                heart_behavior = Behavior_Heart.{animation = heart, default_boredom = 5};
                eat_behavior   = Behavior_Eat.{animation = idle, default_boredom = 1};

                {
                    schedule.hours = Plan.[
                        .NEUTRAL, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .NEUTRAL, .SLEEP,
                        .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP,
                        .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP,
                    ];
                }
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


                idle := Sprite_Animation.{
                    sheet = "Tako-Idle",
                    frame_count = 9,
                    speed = 10.0,
                };

                walk := Sprite_Animation.{
                    sheet = "Tako-Walk",
                    frame_count = 7,
                    speed = 10.0,
                };

                sleep := Sprite_Animation.{
                    sheet = "Tako-Sleep",
                    frame_count = 9,
                    speed = 10.0,
                };

                shock := Sprite_Animation.{
                    sheet = "Tako-Shock",
                    frame_count = 13,
                    speed = 20.0,
                };

                heart := Sprite_Animation.{
                    sheet = "Tako-Heart",
                    frame_count = 16,
                    speed = 8.0,
                };

                {
                    b := New(Behavior_Idle);
                    b.animation = idle;

                    b.default_boredom = 7;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Wander_Floor);
                    b.animation = walk;
                    b.idle_animation = idle;

                    b.default_boredom = 15;

                    array_add(*neutral_behaviors, xx b);
                }

                sleep_behavior = Behavior_Sleep.{animation = sleep, default_boredom = 10};
                shock_behavior = Behavior_Shock.{animation = shock, default_boredom = 0.7};
                heart_behavior = Behavior_Heart.{animation = heart, default_boredom = 3.0};
                eat_behavior   = Behavior_Eat.{animation = idle, default_boredom = 1};

                {
                    schedule.hours = Plan.[
                        .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP,
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL,
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .NEUTRAL, .SLEEP, .SLEEP, .SLEEP, .SLEEP,
                    ];
                }
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

                idle := Sprite_Animation.{
                    sheet = "Clam-Idle",
                    frame_count = 1,
                    speed = 1.0,
                };

                sleep := Sprite_Animation.{
                    sheet = "Clam-Sleep",
                    frame_count = 2,
                    speed = 1.2,
                };

                shock := Sprite_Animation.{
                    sheet = "Clam-Shock",
                    frame_count = 20,
                    speed = 15.0,
                };

                heart := Sprite_Animation.{
                    sheet = "Clam-Heart",
                    frame_count = 1,
                    speed = 0.05,
                };

                {
                    b := New(Behavior_Idle);
                    b.animation = idle;

                    b.default_boredom = 10;

                    array_add(*neutral_behaviors, xx b);
                }

                sleep_behavior = Behavior_Sleep.{animation = sleep, default_boredom = 100};
                shock_behavior = Behavior_Shock.{animation = shock, default_boredom = 1.4};
                heart_behavior = Behavior_Heart.{animation = heart, default_boredom = 2.0};
                eat_behavior   = Behavior_Eat.{animation = idle, default_boredom = 1};

                {
                    schedule.hours = Plan.[
                        .NEUTRAL, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .NEUTRAL, .SLEEP,
                        .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP,
                        .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP, .SLEEP,
                    ];
                }
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

                idle := Sprite_Animation.{
                    sheet = "Jelly-Idle",
                    frame_count = 10,
                    speed = 7.0,
                };

                walk := Sprite_Animation.{
                    sheet = "Jelly-Walk",
                    frame_count = 8,
                    speed = 10.0,
                };

                sleep := Sprite_Animation.{
                    sheet = "Jelly-Sleep",
                    frame_count = 14,
                    speed = 10.0,
                };

                shock := Sprite_Animation.{
                    sheet = "Jelly-Shock",
                    frame_count = 5,
                    speed = 20,
                };

                heart := Sprite_Animation.{
                    sheet = "Jelly-Heart",
                    frame_count = 20,
                    speed = 10.0,
                };

                {
                    b := New(Behavior_Idle);
                    b.animation = idle;

                    b.default_boredom = 7;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Wander_Floor);
                    b.animation = walk;
                    b.idle_animation = idle;

                    b.default_boredom = 4;

                    array_add(*neutral_behaviors, xx b);
                }

                sleep_behavior = Behavior_Sleep.{animation = sleep, default_boredom = 10};
                shock_behavior = Behavior_Shock.{animation = shock, default_boredom = 2};
                heart_behavior = Behavior_Heart.{animation = heart, default_boredom = 8};
                eat_behavior   = Behavior_Eat.{animation = idle, default_boredom = 1};
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

                idle := Sprite_Animation.{
                    sheet = "Blowfish-Idle",
                    frame_count = 8,
                    speed = 7.0,
                };

                walk := Sprite_Animation.{
                    sheet = "Blowfish-Walk",
                    frame_count = 5,
                    speed = 10.0,
                };

                heart := Sprite_Animation.{
                    sheet = "Blowfish-Happy",
                    frame_count = 10,
                    speed = 10.0,
                };

                sleep := Sprite_Animation.{
                    sheet = "Blowfish-Sleep",
                    frame_count = 21,
                    speed = 10.0,
                };

                shock := Sprite_Animation.{
                    sheet = "Blowfish-Shock",
                    frame_count = 1,
                    speed = 0.1,
                };

                {
                    b := New(Behavior_Wander);
                    b.animation = walk;
                    b.idle_animation = idle;

                    b.swimming = true;

                    b.default_boredom = 5;

                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Swim);
                    b.animation = walk;

                    b.speed = 15;

                    b.swimming = true;

                    b.default_boredom = 5;

                    array_add(*neutral_behaviors, xx b);
                }

                sleep_behavior = Behavior_Sleep.{animation = sleep, swimming = true, default_boredom = 30};
                shock_behavior = Behavior_Shock.{animation = shock, swimming = true, default_boredom = 5};
                heart_behavior = Behavior_Heart.{animation = heart, swimming = true, default_boredom = 10};
                eat_behavior   = Behavior_Eat.{animation = idle, swimming = true, default_boredom = 1};

                {
                    schedule.hours = Plan.[
                        .SLEEP, .SLEEP, .SLEEP, .NEUTRAL, .SLEEP, .SLEEP, .SLEEP, .SLEEP,
                        .NEUTRAL, .NEUTRAL, .NEUTRAL, .EAT, .EAT, .EAT, .NEUTRAL, .NEUTRAL,
                        .NEUTRAL, .NEUTRAL, .EAT, .EAT, .SLEEP, .SLEEP, .SLEEP, .SLEEP,
                    ];
                }
            }
        }

        // Debug checks
        {
            array_add(*game.entities, xx frog);
            array_add(*game.simulation.actors, *frog.actor);

            array_add(*game.entities, xx tako);
            array_add(*game.simulation.actors, *tako.actor);

            array_add(*game.entities, xx clam);
            array_add(*game.simulation.actors, *clam.actor);

            array_add(*game.entities, xx jelly);
            array_add(*game.simulation.actors, *jelly.actor);

            array_add(*game.entities, xx blowfish);
            array_add(*game.simulation.actors, *blowfish.actor);
        }

        /*
        // Populate for real.
        {
            // Seed the population generator with the hour and the date.
            // This way, it doesn't feel like you're just rolling the dice every time you open the app.
            random_state : Random_State;
            {
                t := time();
                seed : u64 = cast(u64)t.hour + (cast(u64)t.day_of_week_starting_at_0 << 8);

                random_seed(*random_state, seed);
            }

            guys := *Guy.[frog, tako, clam, jelly, blowfish];
            guys_in_the_tank : int;
            for guy : guys {
                roll := random_get_zero_to_one(*random_state);
                print("%\n", roll);
                if roll <= get_probability(guy.rarity) {
                    array_add(*game.entities, xx guy);
                    array_add(*game.simulation.actors, *guy.actor);
                    guys_in_the_tank += 1;
                }
            }

            // Gotta have at least one...
            if guys_in_the_tank == 0 {
                guy := random_choice(guys);
                array_add(*game.entities, xx guy);
                array_add(*game.simulation.actors, *guy.actor);
                guys_in_the_tank += 1;
            }
        }
        */
    }
}
