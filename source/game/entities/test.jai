// Dayne
// Test (Entity)
// September 2024

Test :: struct {
    using entity : Entity;
    kind = .TEST;

    using position : Vector2;
}

initialize :: (using test: *Test) {
    position = .{};
}

update :: (using test: *Test, dt: float) {
    position.x += 1.0 * dt;
}

draw :: (using test: Test) {
    screen_position := world_space_to_screen_pixel(xx x, xx y);

    sprite := table_find_pointer(*graphics_context.sprites, "haruhachi");
    if !sprite {
        log_error("Couldn't load Test sprite.\n");
        return;
    }

    draw_sprite(
        sprite,
        frame = 0,
        pixel = screen_position,

        scale_factor = 1,

        horizontal_flip = false,

        use_color_override = false,
    );
}
