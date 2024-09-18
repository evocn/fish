// Dayne
// Game
// August 2024

#load "level.jai";

#load "entity.jai";
#load "entity_serialization.jai";
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

    success : bool;

    success = load_entities(*game.entities, "1");
    assert(success);
    return;

    /*
    particle_system : *Particle_System = xx new_entity(.PARTICLE_SYSTEM);
    array_add(*game.entities, xx particle_system);

    test : *Test = xx new_entity(.TEST);
    array_add(*game.entities, xx test);

    // Load Entities (Hardcoded for now)
    blowfish : *Guy = xx new_entity(.GUY);
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

        blowfish.animation_idle = animation_integer_make(
            value = *blowfish.frame,
            duration = 1.0,
            keyframes = ...[
                .{time=0.0, value=1},
            ],
        );

        blowfish.animation_walk = animation_integer_make(
            value = *blowfish.frame,
            duration = 1.0,
            keyframes = ...[
                .{time=0.0, value=7},
            ],
        );

        array_add(*game.entities, xx blowfish);
    }

    jellyfish : *Guy = xx new_entity(.GUY);
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
                .{time=0.0, value=0},
                .{time=0.4, value=1},
            ],
        );

        jellyfish.animation_walk = animation_integer_make(
            value = *jellyfish.frame,
            duration = 0.3,
            keyframes = ...[
                .{time=0.0,  value=2},
                .{time=0.15, value=3},
            ],
        );

        array_add(*game.entities, xx jellyfish);
    }


    frog : *Guy = xx new_entity(.GUY);
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
                .{time=0.0, value=0},
                .{time=1.0, value=1},
            ],
        );

        frog.animation_walk = animation_integer_make(
            value = *frog.frame,
            duration = 0.8,
            keyframes = ...[
                .{time=0.0, value=2},
                .{time=0.2, value=0},
                .{time=0.4, value=3},
                .{time=0.6, value=1},
            ],
        );

        array_add(*game.entities, xx frog);
    }

    success = save_entities(game.entities, "1");
    assert(success);
    */
}
