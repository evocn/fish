// Dayne
// Toy (Entity)
// October 2024

Toy :: struct {
    using entity : Entity;
    kind = .TOY;

    z_index = -50;

    using collider : Collider;

    name : string;

    animation : *Sprite_Animation;

    // State
    facing_left : bool; @NoSerialize
}

initialize :: (using toy: *Toy) {
    facing_left = false;
}

update :: (using toy: *Toy, dt: float) {
    update(animation, dt);
}

draw :: (using toy: Toy) {
    draw_sprite_relative_to_collider(
        collider, animation.sheet, animation.frame, facing_left
    );
}

draw_debug :: (using toy: *Toy) {
    draw(collider, color=debug.unique_color);
}
