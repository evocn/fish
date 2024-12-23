// Dayne
// Jet (Entity)
// December 2024

Jet :: struct {
    using entity : Entity;
    kind = .JET;

    using collider : Collider;
    acceleration := 0.5;

    animation : Sprite_Animation;
}

initialize :: (using jet: *Jet) {
}

update :: (using jet: *Jet, dt: float) {
    update(*animation, dt);
}

draw :: (using jet: Jet) {
    draw_sprite_relative_to_collider(
        collider, animation.sheet, animation.frame
    );
}

draw_debug :: (using jet: *Jet) {
    draw(collider, color=debug.unique_color);
}
