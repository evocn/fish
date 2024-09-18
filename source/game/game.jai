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

    success : bool;

    // Serialization path
    /*
    success = load_entities(*game.entities, "1");
    assert(success);
    */

    particle_system : *Particle_System = xx new_entity(.PARTICLE_SYSTEM);
    {
        using particle_system;
    }
    array_add(*game.entities, xx particle_system);

    /*
    test : *Test = xx new_entity(.TEST);
    array_add(*game.entities, xx test);
    */

    // Load Entities (Hardcoded for now)
    blowfish : *Guy = xx new_entity(.GUY);
    {
        using blowfish;

        sheet = "blowfish";
        sprite = 2;

        x = 0;
        y = 16;
        width  = 14;
        height = 14;

        ai.state = .DEBUG;

        speed = 15;

        array_add(*game.simulation.actors, *actor);

        animation_idle = animation_integer_make(
            value = *frame,
            duration = 1.0,
            keyframes = ...[
                .{time=0.0, value=0},
                .{time=0.5, value=8},
            ],
        );

        animation_walk = animation_integer_make(
            value = *frame,
            duration = 0.4,
            keyframes = ...[
                .{time=0.0, value=0},
                .{time=0.2, value=8},
            ],
        );
    }
    array_add(*game.entities, xx blowfish);

    jellyfish : *Guy = xx new_entity(.GUY);
    {
        using jellyfish;
        sheet = "jellyfish";
        sprite = 1;

        speed = 6;

        x = 32;
        y = 16;
        width  = 4;
        height = 4;

        ai.state = .SPIN;

        array_add(*game.simulation.actors, *actor);

        animation_idle = animation_integer_make(
            value = *frame,
            duration = 0.8,
            keyframes = ...[
                .{time=0.0, value=0},
                .{time=0.4, value=8},
            ],
        );

        animation_walk = animation_integer_make(
            value = *frame,
            duration = 0.6,
            keyframes = ...[
                .{time=0.0,  value=1},
                .{time=0.15, value=9},
                .{time=0.30, value=17},
                .{time=0.45, value=25},
            ],
        );
    }
    array_add(*game.entities, xx jellyfish);


    frog : *Guy = xx new_entity(.GUY);
    {
        using frog;

        sheet = "frog";
        sprite = 3;

        x = 100;
        y = 16;
        width  = 12;
        height = 12;

        speed = 10;

        ai.state = .WANDER_FLOOR;

        array_add(*game.simulation.actors, *actor);

        animation_idle = animation_integer_make(
            value = *frame,
            duration = 2.0,
            keyframes = ...[
                .{time=0.0, value=0},
                .{time=1.0, value=8},
            ],
        );

        animation_walk = animation_integer_make(
            value = *frame,
            duration = 0.8,
            keyframes = ...[
                .{time=0.0, value=1},
                .{time=0.2, value=9},
                .{time=0.4, value=17},
                .{time=0.6, value=25},
            ],
        );
    }
    array_add(*game.entities, xx frog);

    clam : *Guy = xx new_entity(.GUY);
    {
        using clam;

        sheet = "clam";
        sprite = 3;

        x = 160;
        y = 80;
        width  = 16;
        height = 16;

        speed = 0;

        ai.state = .SIT;

        array_add(*game.simulation.actors, *actor);

        animation_idle = animation_integer_make(
            value = *frame,
            duration = 4.0,
            keyframes = ...[
                .{time=0.0, value=2},
                .{time=1.0, value=10},
                .{time=2.0, value=18},
                .{time=3.0, value=26},
            ],
        );

        animation_walk = animation_integer_make(
            value = *frame,
            duration = 1.0,
            keyframes = ...[
                .{time=0.0, value=1},
            ],
        );
    }
    array_add(*game.entities, xx clam);


    /*
    success = save_entities(game.entities, "1");
    assert(success);
    */
}
