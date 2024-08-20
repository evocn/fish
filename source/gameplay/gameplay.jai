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
    for entity : game.entities {
        update(entity, dt);
    }
}
