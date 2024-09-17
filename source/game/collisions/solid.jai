// Dayne
// Solid
// August 2024

Solid :: struct {
    using collider: Collider;
    x_remainder : float;
    y_remainder : float;

    collidable  : bool = true;
    one_way     : bool = false;
}

get_riding_actors :: (solid: Solid, actors: [..] *Actor) -> [..] *Actor {
    result : [..] *Actor;
    result.allocator = temp;

    for actor : actors {
        if is_riding(actor, solid) {
            array_add(*result, actor);
        }
    }

    return result;
}

move :: (solid: *Solid, x: float, y: float) {
    relevant_actors := game.simulation.actors;
    riding_actors   := get_riding_actors(solid, relevant_actors);

    solid.x_remainder += x;
    solid.y_remainder += y;   
    x_movement := round(solid.x_remainder);
    y_movement := round(solid.y_remainder);

    if x_movement != 0 || y_movement != 0 {
        // Make this Solid temporarily non-collidable for Actors,
        // so that Actors moved by it do not get stuck on it
        solid.collidable = false;
        defer solid.collidable = true;

        if x_movement != 0 {
            solid.x_remainder -= x_movement;
            solid.x += x_movement;

            if x_movement > 0 {
                for actor : relevant_actors {
                    // Push right
                    if collision(solid.collider, actor.collider) {
                        if !solid.one_way {
                            move_x(actor, xx ((solid.x + solid.width) - actor.x), squish);
                        }
                    }
                    // Carry right
                    else if array_find(riding_actors, actor) {
                        move_x(actor, xx x_movement, null);
                    }
                }
            } else {
                for actor : relevant_actors {
                    // Push left
                    if collision(solid.collider, actor.collider) {
                        if !solid.one_way {
                            move_x(actor, xx (solid.x - (actor.x + actor.width)), squish);
                        }
                    }
                    // Carry left
                    else if array_find(riding_actors, actor) {
                        move_x(actor, xx x_movement, null);
                    }
                }
            }
        }


        if y_movement != 0 {
            solid.y_remainder -= y_movement;
            solid.y += y_movement;

            if y_movement > 0 {
                for actor : relevant_actors {
                    // Push up
                    if collision(solid.collider, actor.collider) {
                        // @NOTE: This is picky, because one way solids can only push things up, and only things which start out above them.
                        if solid.one_way && solid.y + solid.height - y_movement <= actor.y {
                            move_y(actor, xx ((solid.y + solid.height) - actor.y), squish);
                        }
                    }
                    // Carry up
                    else if array_find(riding_actors, actor) {
                        move_y(actor, xx y_movement, null);
                    }
                }
            } else {
                for actor : relevant_actors {
                    // Push down
                    if collision(solid.collider, actor.collider) {
                        if !solid.one_way {
                            move_y(actor, xx (solid.y - (actor.y + actor.height)), squish);
                        }
                    }
                    // Carry down
                    else if array_find(riding_actors, actor) {
                        move_y(actor, xx y_movement, null);
                    }
                }
            }
        }
    }
}
