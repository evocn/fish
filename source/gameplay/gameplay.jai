// Dayne
// Gameplay
// August 2024

#load "level.jai";

#load "entity.jai";
#load "guy.jai";
#load "tile.jai";
#load "ai.jai";

#load "physics/collider.jai";
#load "physics/actor.jai";
#load "physics/solid.jai";
#load "physics/simulate.jai";

//

simulate :: (game: *Game, dt: float) {
    if simulation_state.paused {
        if simulation_state.step {
            simulation_state.step = false;
        }
        else {
            return;
        }
    }

    for entity : game.entities {
        update(entity, dt);
    }
}
