// Dayne
// Simulation
// August 2024

#load "collider.jai";
#load "actor.jai";
#load "solid.jai";

// All colliders are axis-aligned bounding boxes (AABBs)
// All collider positions, widths, and heights are integer numbers
// Except for special circumstances, Actors and Solids will never overlap
// Solids do not interact with other Solids

Simulation :: struct {
    actors : [..] *Actor;
    solids : [..] *Solid;
}

reset_simulation :: (simulation: *Simulation) {
    array_reset(*simulation.actors);
    array_reset(*simulation.solids);
}

// Utilities

filter_irrelevant_solids :: (solids: [..] *Solid, actor: *Actor) -> [] *Solid {
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
