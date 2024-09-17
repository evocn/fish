// Dayne
// Actor
// August 2024

Actor :: struct {
    using collider: Collider;
    x_remainder: float;
    y_remainder: float;
    is_squished: bool;
}

move_x :: (actor: *Actor, amount: float, on_collided: (*Actor) -> ()) -> collided : bool {
    relevant_solids := filter_irrelevant_solids(game.simulation.solids, actor);

    actor.x_remainder += amount;
    move := round(actor.x_remainder);

    if (move == 0) return false;

    actor.x_remainder -= move;
    sign := move / abs(move);

    while move != 0 {
        new_collider := actor.collider;
        new_collider.x = actor.collider.x + sign;

        collides := check_collision_against_all_solids(new_collider, relevant_solids);

        if collides {
            if on_collided then on_collided(actor);
            return true;
        }

        actor.collider.x = new_collider.x;
        move -= sign;
    }

    return false;
}

move_y :: (actor: *Actor, amount: float, on_collided: (*Actor) -> ()) -> collided: bool {
    relevant_solids := filter_irrelevant_solids(game.simulation.solids, actor);

    actor.y_remainder += amount;
    move := round(actor.y_remainder);

    if (move == 0) return false;

    actor.y_remainder -= move;
    sign := move / abs(move);

    while move != 0 {
        new_collider := actor.collider;
        new_collider.y = actor.collider.y + sign;

        collides := check_collision_against_all_solids(new_collider, relevant_solids);

        if collides {
            if on_collided then on_collided(actor);
            return true;
        }

        actor.collider.y = new_collider.y;
        move -= sign;
    }

    return false;
}

is_riding :: (actor: *Actor, solid: Solid) -> bool {
    extended_collider := actor.collider;
    extended_collider.y -= 1;

    if collision(extended_collider, solid.collider) {
        return true;
    }

    return false;
}

squish :: (actor: *Actor) {
    actor.is_squished = true;
}
