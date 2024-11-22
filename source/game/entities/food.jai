// Dayne
// Food
// November 2024

Food :: struct {
    using entity: Entity;
    kind = .FOOD;

    using actor : Actor;
    width  = 4;
    height = 4;

    velocity : Vector2;

    color := yellow;
}

initialize :: (using food: *Food) {
    velocity = .{};
    array_add(*game.simulation.actors, *actor);
}

update :: (using food: *Food, dt: float) {
    // Update acceleration
    velocity.y += game.GRAVITY * dt;

    // Move
    {
        amount_to_move := velocity * dt;

        collided_x := move_x(*actor, amount_to_move.x, null);
        if collided_x then velocity.x = 0;

        collided_y := move_y(*actor, amount_to_move.y, null);
        if collided_y then velocity.y = 0;

        tank_collisions(*actor, *velocity);
    }
}

draw :: (using food: *Food) {
    draw_sprite_relative_to_collider(
        collider, "Food"
    );
}
