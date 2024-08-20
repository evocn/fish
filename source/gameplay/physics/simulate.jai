// Dayne
// Simulate
// August 2024

Simulation :: struct {
    actors : [..] *Entity;
    solids : [..] *Solid;
}
simulation : Simulation;

reset_simulation :: (simulation: *Simulation) {
    array_reset(*simulation.actors);
    array_reset(*simulation.solids);
}

// Utilities

filter_irrelevant_solids :: (solids: [..] *Solid, actor: *Entity) -> [] *Solid {
    result : [..] *Solid;
    result.allocator = temp;

    for solid : solids {
        if solid.one_way {
            if solid.collider.y + solid.collider.height <= actor.collider.y {
                array_add(*result, solid);
            }
        }
        else {
            array_add(*result, solid);
        }
    }

    return result;
}
