// Dayne
// Game
// August 2024

#load "level.jai";

#load "entity.jai";
//#load "entity_serialization.jai";
#load "tile.jai";
#load "ai.jai";

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

    particle_system : *Particle_System = xx new_entity(*game.entities, .PARTICLE_SYSTEM);

    test : *Test = xx new_entity(*game.entities, .TEST);

    // Load Entities (Hardcoded for now)
    blowfish : *Guy = xx new_entity(*game.entities, .GUY);
    {
        blowfish.sheet = "blowfish";
        blowfish.sprite = 2;

        blowfish.x = 0;
        blowfish.y = 16;
        blowfish.width  = 14;
        blowfish.height = 14;

        blowfish.ai.state = .DEBUG;

        blowfish.speed = 150;

        array_add(*game.simulation.actors, *blowfish.actor);

        blowfish.animation_sleep = animation_integer_make(
            value = *blowfish.frame,
            duration = 2.0,
            keyframes = ...[
                .{0.0, 4},
                .{1.0, 5},
            ],
        );

        blowfish.animation_idle = animation_integer_make(
            value = *blowfish.frame,
            duration = 1.0,
            keyframes = ...[
                .{0.0, 1},
            ],
        );

        blowfish.animation_walk = animation_integer_make(
            value = *blowfish.frame,
            duration = 1.0,
            keyframes = ...[
                .{0.0, 7},
            ],
        );

        blowfish.animation_talk = animation_integer_make(
            value = *blowfish.frame,
            duration = 0.4,
            keyframes = ...[
                .{0.0,   9},
                .{0.25,  10},
            ],
        );

        blowfish.animation_dance = animation_integer_make(
            value = *blowfish.frame,
            duration = 0.6,
            keyframes = ...[
                .{0.0,  10},
                .{0.15, 0},
            ],
        );
    }

    jellyfish : *Guy = xx new_entity(*game.entities, .GUY);
    {
        jellyfish.sheet = "jellyfish";
        jellyfish.sprite = 1;

        jellyfish.speed = 6;

        jellyfish.x = 32;
        jellyfish.y = 16;
        jellyfish.width  = 4;
        jellyfish.height = 4;

        jellyfish.ai.state = .SPIN;

        array_add(*game.simulation.actors, *jellyfish.actor);

        jellyfish.animation_idle = animation_integer_make(
            value = *jellyfish.frame,
            duration = 0.8,
            keyframes = ...[
                .{0.0, 0},
                .{0.4, 1},
            ],
        );

        jellyfish.animation_walk = animation_integer_make(
            value = *jellyfish.frame,
            duration = 0.3,
            keyframes = ...[
                .{0.0,  2},
                .{0.15, 3},
            ],
        );

        jellyfish.animation_sleep = animation_integer_make(
            value = *jellyfish.frame,
            duration = 3.0,
            keyframes = ...[
                .{0.0,  4},
                .{1.5,  5},
            ],
        );

        jellyfish.animation_talk   = jellyfish.animation_idle;
        jellyfish.animation_dance  = jellyfish.animation_idle;
    }


    frog : *Guy = xx new_entity(*game.entities, .GUY);
    {
        frog.sheet = "frog";
        frog.sprite = 3;

        frog.x = 100;
        frog.y = 16;
        frog.width  = 12;
        frog.height = 12;

        frog.speed = 10;

        frog.ai.state = .WANDER;

        array_add(*game.simulation.actors, *frog.actor);

        frog.animation_idle = animation_integer_make(
            value = *frog.frame,
            duration = 2.0,
            keyframes = ...[
                .{0.0, 0},
                .{1.0, 1},
            ],
        );

        frog.animation_walk = animation_integer_make(
            value = *frog.frame,
            duration = 0.8,
            keyframes = ...[
                .{0.0, 2},
                .{0.2, 0},
                .{0.4, 3},
                .{0.6, 1},
            ],
        );

        frog.animation_sleep = animation_integer_make(
            value = *frog.frame,
            duration = 1.5,
            keyframes = ...[
                .{0.0, 4},
                .{0.5, 5},
            ],
        );

        frog.animation_talk   = frog.animation_idle;
        frog.animation_dance  = frog.animation_idle;
    }
}
