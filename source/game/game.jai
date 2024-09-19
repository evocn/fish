// Dayne
// Game
// August 2024

#load "level.jai";

#load "entity.jai";
//#load "entity_serialization.jai";
#load "tile.jai";
#load "ai.jai";

#load "sprite_animation.jai";

#load "entities/test.jai";
#load "entities/guy.jai";
#load "entities/particle_system.jai";

#load "collisions/simulation.jai";


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
            width  = 12;
            height = 12;

            speed = 10;

            ai.state = .WANDER_FLOOR;

            array_add(*animations,
                Sprite_Animation.{
                    sheet = "Frog-Idle",
                    frame_count = 2,
                    speed = 1.0,
                }
            );

            array_add(*animations,
                Sprite_Animation.{
                    sheet = "Frog-Walk",
                    frame_count = 4,
                    speed = 4.0,
                }
            );

            assert(animations.count > 0);
            animation = *animations[0];
        }
        array_add(*game.entities, xx frog);
        array_add(*game.simulation.actors, *frog.actor);


        tako : *Guy = xx new_entity(.GUY);
        {
            using tako;

            name = "tako";

            x = 32;
            y = 16;
            width  = 10;
            height = 10;

            speed = 10;

            ai.state = .SIT;

            array_add(*animations,
                Sprite_Animation.{
                    sheet = "Tako-Idle",
                    frame_count = 9,
                    speed = 10.0,
                }
            );

            assert(animations.count > 0);
            animation = *animations[0];
        }
        array_add(*game.entities, xx tako);
        array_add(*game.simulation.actors, *tako.actor);

        clam : *Guy = xx new_entity(.GUY);
        {
            using clam;

            name = "clam";

            x = 160;
            y = 16;
            width  = 16;
            height = 16;

            speed = 0;

            ai.state = .SIT;

            array_add(*animations,
                Sprite_Animation.{
                    sheet = "Clam-Idle",
                    frame_count = 1,
                    speed = 1.0,
                }
            );

            array_add(*animations,
                Sprite_Animation.{
                    sheet = "Clam-Surprised",
                    frame_count = 20,
                    speed = 10.0,
                }
            );

            assert(animations.count > 0);
            animation = *animations[1];
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

            ai.state = .WANDER_FLOOR;

            array_add(*animations,
                Sprite_Animation.{
                    sheet = "Jelly-Idle",
                    frame_count = 2,
                    speed = 5.0,
                }
            );

            array_add(*animations,
                Sprite_Animation.{
                    sheet = "Jelly-Walk",
                    frame_count = 2,
                    speed = 10.0,
                }
            );

            assert(animations.count > 0);
            animation = *animations[0];
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

            ai.state = .WANDER;

            array_add(*animations,
                Sprite_Animation.{
                    sheet = "Blowfish-Happy",
                    frame_count = 10,
                    speed = 10.0,
                }
            );

            assert(animations.count > 0);
            animation = *animations[0];

            velocity = .{20, 10};
        }
        array_add(*game.entities, xx blowfish);
        array_add(*game.simulation.actors, *blowfish.actor);
    }
}
