// Dayne
// Particle System
// September 2024

Particle_System :: struct {
    using entity: Entity;
    kind = .PARTICLE_SYSTEM;

    color : Color;

    // A more complicated particle system probably looks like this:
    /*
    one_shot : bool; // Whether or not particles respawn when their lifetime ends.
    count : int;
    lifetime : float; // Maybe better as a range.
    initial_velocity : Vector2;
    constant_acceleration : Vector2 = .{};
    initial_range : Pair;
    */

    particles : [1000] Particle; @NoSerialize

    using rendering_details : struct {
        vao, vbo : GLuint;
        vbo_data : [..] float;
    }
}

initialize :: (using particle_system: *Particle_System) {
    generate_particle :: (particle: *Particle, color : Color) {
        particle.color = color;
        particle.position = .{random(0, PIXEL_WIDTH), random(0, PIXEL_HEIGHT)};
        particle.velocity = .{1, 0};
    }

    for * particle: particles {
        generate_particle(particle, random_color());
    }

    // Rendering Details
    {
        glGenVertexArrays(1, *vao);
        glGenBuffers(1, *vbo);

        glBindVertexArray(vao);
        defer glBindVertexArray(0);

        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        defer glBindBuffer(GL_ARRAY_BUFFER, 0);

        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, cast(*void)0);
        glEnableVertexAttribArray(0);

        array_resize(*vbo_data, particles.count * 2);
    }
}

update :: (using particle_system: *Particle_System, dt: float) {
    for * particle: particles {
        update(particle, dt);
        screen_pixel := world_space_to_screen_pixel(xx particle.x, xx particle.y);
        vbo_data[it_index * 2 + 0] = (cast(float)screen_pixel.x / PIXEL_WIDTH);
        vbo_data[it_index * 2 + 1] = (cast(float)screen_pixel.y / PIXEL_HEIGHT);
    }

    {
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        defer glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBufferData(
            GL_ARRAY_BUFFER,
            vbo_data.count * size_of(float),
            *vbo_data[0],
            GL_DYNAMIC_DRAW,
        );
    }
}

draw :: (using particle_system: Particle_System) {
    glBindVertexArray(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);

    shader := use_basic_shader();

    model := Matrix4_Identity;
    set_mat4(shader, "model", model);
    //set_vec4(shader, "color", white);

    //glDrawArrays(GL_POINTS, 0, xx vbo_data.count);

    for particle, index: particles {
        set_vec4(shader, "color", particle.color);
        glDrawArrays(GL_POINTS, xx (index * 2), 2);
    }
}

////////////////////////////////////////////////////////////////////////////////

Particle :: struct {
    // Properties
    color : Color;

    // State
    using position : Vector2;
    velocity : Vector2;
}

update :: (particle : *Particle, dt: float) {
    particle.position += particle.velocity * dt;

    // Update Velocity based on gravity, forces, ... below.
}
