// Dayne
// Game
// August 2024

#load "level.jai";

#load "entity.jai";
//#load "entity_serialization.jai";
#load "tile.jai";

#load "personality.jai";
#load "behavior.jai";

#load "sprite_animation.jai";

#load "entities/test.jai";
#load "entities/guy.jai";
#load "entities/particle_system.jai";

#load "collisions/simulation.jai";

#load "interaction.jai";

Game :: struct {
    player : Player_Interface;

    level : Level;
    entities : [..] *Entity;

    simulation : Simulation;

    camera : Pair;
}


simulate :: (game: *Game, dt: float) {
    for entity : game.entities {
        update(entity, dt);
    }

    game.camera = .{};

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

        // Load Guys

        frog : *Guy = xx new_entity(.GUY);
        {
            using frog;

            name = "frog";

            x = 100;
            y = 16;
            width  = 14;
            height = 14;

            speed = 10;

            {
                using personality;

                idle := Sprite_Animation.{
                    sheet = "Frog-Idle",
                    frame_count = 2,
                    speed = 1.0,
                };

                walk := Sprite_Animation.{
                    sheet = "Frog-Walk",
                    frame_count = 4,
                    speed = 4.0,
                };

                sleep := Sprite_Animation.{
                    sheet = "Frog-Sleep",
                    frame_count = 2,
                    speed = 1.0,
                };

                shock := Sprite_Animation.{
                    sheet = "Frog-Shock",
                    frame_count = 2,
                    speed = 1.0,
                };

                {
                    b := New(Behavior_Idle);
                    b.animation = idle;

                    b.default_boredom = 30;

                    reset(b);
                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Wander_Floor);
                    b.animation = walk;
                    b.idle_animation = idle;

                    b.default_boredom = 4;

                    reset(b);
                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Wander);
                    b.animation = walk; // @TODO
                    b.idle_animation = idle;

                    b.default_boredom = 20;

                    reset(b);
                    array_add(*neutral_behaviors, xx b);
                }

                current_whim = random_choice(neutral_behaviors);

                sleep_behavior = Behavior_Sleep.{animation = sleep, default_boredom = 50};
                shock_behavior = Behavior_Shock.{animation = shock, default_boredom = 1};
                heart_behavior = Behavior_Heart.{};
            }
        }
        array_add(*game.entities, xx frog);
        array_add(*game.simulation.actors, *frog.actor);


        tako : *Guy = xx new_entity(.GUY);
        {
            using tako;

            name = "tako";

            x = 32;
            y = 16;
            width  = 15;
            height = 15;

            speed = 10;

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

                    reset(b);
                    array_add(*neutral_behaviors, xx b);
                }

                current_whim = random_choice(neutral_behaviors);

                sleep_behavior = Behavior_Sleep.{animation = sleep, default_boredom = 10};
                shock_behavior = Behavior_Shock.{animation = shock, default_boredom = 0.7};
                heart_behavior = Behavior_Heart.{};
            }
        }
        array_add(*game.entities, xx tako);
        array_add(*game.simulation.actors, *tako.actor);

        clam : *Guy = xx new_entity(.GUY);
        {
            using clam;

            name = "clam";

            x = 160;
            y = 80;
            width  = 16;
            height = 16;

            speed = 0;

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

                {
                    b := New(Behavior_Idle);
                    b.animation = idle;

                    b.default_boredom = 40;

                    reset(b);
                    array_add(*neutral_behaviors, xx b);
                }

                current_whim = random_choice(neutral_behaviors);

                sleep_behavior = Behavior_Sleep.{animation = sleep, default_boredom = 100};
                shock_behavior = Behavior_Shock.{animation = shock, default_boredom = 1.4};
                heart_behavior = Behavior_Heart.{};
            }
        }
        array_add(*game.entities, xx clam);
        array_add(*game.simulation.actors, *clam.actor);

        jelly : *Guy = xx new_entity(.GUY);
        {
            using jelly;

            name = "jelly";

            x = 128;
            y = 16;
            width  = 16;
            height = 16;

            speed = 30;

            {
                using personality;

                idle := Sprite_Animation.{
                    sheet = "Jelly-Idle",
                    frame_count = 2,
                    speed = 5.0,
                };

                walk := Sprite_Animation.{
                    sheet = "Jelly-Walk",
                    frame_count = 2,
                    speed = 10.0,
                };

                sleep := Sprite_Animation.{
                    sheet = "Jelly-Sleep",
                    frame_count = 14,
                    speed = 10.0,
                };

                shock := Sprite_Animation.{
                    sheet = "Jelly-Shock",
                    frame_count = 2,
                    speed = 10.0,
                };

                {
                    b := New(Behavior_Idle);
                    b.animation = idle;

                    b.default_boredom = 7;

                    reset(b);
                    array_add(*neutral_behaviors, xx b);
                }

                {
                    b := New(Behavior_Wander_Floor);
                    b.animation = walk;
                    b.idle_animation = idle;

                    b.default_boredom = 4;

                    reset(b);
                    array_add(*neutral_behaviors, xx b);
                }

                current_whim = random_choice(neutral_behaviors);

                sleep_behavior = Behavior_Sleep.{animation = sleep, default_boredom = 10};
                shock_behavior = Behavior_Shock.{animation = shock, default_boredom = 2};
                heart_behavior = Behavior_Heart.{};
            }
        }
        array_add(*game.entities, xx jelly);
        array_add(*game.simulation.actors, *jelly.actor);

        blowfish : *Guy = xx new_entity(.GUY);
        {
            using blowfish;

            name = "blowfish";

            x = 64;
            y = 64;
            width  = 16;
            height = 16;

            speed = 20;

            {
                using personality;

                heart := Sprite_Animation.{
                    sheet = "Blowfish-Happy",
                    frame_count = 10,
                    speed = 10.0,
                };

                sleep := Sprite_Animation.{
                    sheet = "Blowfish-Sleep",
                    frame_count = 2,
                    speed = 1.0,
                };

                shock := Sprite_Animation.{
                    sheet = "Blowfish-Shock",
                    frame_count = 1,
                    speed = 1.0,
                };

                {
                    b := New(Behavior_Wander);
                    b.animation = heart;
                    b.idle_animation = heart;

                    b.default_boredom = 5;
                    reset(b);

                    array_add(*neutral_behaviors, xx b);
                }

                current_whim = random_choice(neutral_behaviors);

                sleep_behavior = Behavior_Sleep.{animation = sleep, default_boredom = 30};
                shock_behavior = Behavior_Shock.{animation = shock, default_boredom = 50};
                heart_behavior = Behavior_Heart.{};
            }
        }
        array_add(*game.entities, xx blowfish);
        array_add(*game.simulation.actors, *blowfish.actor);
    }
}
