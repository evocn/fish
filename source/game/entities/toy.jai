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
    sprite := table_find_pointer(*graphics_context.sheets, animation.sheet);
    if !sprite {
        log_error("Couldn't load Toy sprite %.\n", animation.sheet);
        return;
    }

    screen_pixel := world_space_to_screen_pixel(xx x, xx y);

    bottom_left_corner_of_sprite :=
          screen_pixel                  // Bottom left corner of collider
        + .{width / 2, 0}               // Gets us the center bottom of collider
        - .{sprite.tile_width_in_pixels / 2, 0} // Bottom left corner!
    ;

    scale := screen_pixel_zoom();

    draw_sprite(
        sprite,
        index = animation.frame,
        pixel = bottom_left_corner_of_sprite,

        scale_factor = scale,

        horizontal_flip = facing_left,

        use_color_override = false,
    );
}

draw_debug :: (using toy: *Toy) {
    draw(collider, color=debug.unique_color);
}
