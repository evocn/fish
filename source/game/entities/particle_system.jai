// Dayne
// Particle System
// September 2024

Particle_System :: struct {
    using entity: Entity;
    kind = .PARTICLE_SYSTEM;

    position : Pair;

    // Properties
    one_shot : bool; // Whether or not particles respawn when their lifetime ends.
    lifetime_min : float;
    lifetime_max : float;

    initial_velocity_min : Vector2;
    initial_velocity_max : Vector2;

    initial_acceleration_min : Vector2;
    initial_acceleration_max : Vector2;

    custom_initializer: (*Particle, *Particle_System);

    // State
    particles : [100] Particle; @NoSerialize

    using rendering_details : struct {
        vao, vbo : GLuint;
        vbo_data : [..] float;
    } @NoSerialize
}

initialize_particle :: (using particle: *Particle, particle_system: *Particle_System) {
    t = 0;

    if particle_system.custom_initializer {
        particle_system.custom_initializer(particle, particle_system);
    }

    velocity = random(particle_system.initial_velocity_min, particle_system.initial_velocity_max);
    acceleration = random(particle_system.initial_acceleration_min, particle_system.initial_acceleration_max);
    lifetime = random(particle_system.lifetime_min, particle_system.lifetime_max);
}

background_particle_initializer :: (using particle: *Particle, particle_system: *Particle_System) {
    color = random_choice(Color.[white, blue, blue, blue, blue, blue, blue, teal, green, pink, yellow]);
    position = .{random(0, PIXEL_WIDTH), random(0, PIXEL_HEIGHT)};
}

dustcloud_particle_initializer :: (using particle: *Particle, particle_system: *Particle_System) {
    color = random_choice(Color.[yellow, yellow, yellow, yellow, green, brown]);
    position = to_vector(particle_system.position);
}

initialize :: (using particle_system: *Particle_System) {
    for * particle: particles {
        initialize_particle(particle, particle_system);
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

set_count :: (using particle_system: *Particle_System, count: int) {
    for * particle, index : particles {
        if index > count then particle.dead = true;
    }
}

update :: (using particle_system: *Particle_System, dt: float) {
    for * particle: particles {
        update(particle, dt);

        if particle.t > particle.lifetime {
            if one_shot {
                particle.dead = true;
            }
            else {
                initialize_particle(particle, particle_system);
            }
        }

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

    // Check if there's any particles left.
    if one_shot {
        everyone_is_dead := true;

        for * particle : particles {
            if !particle.dead then everyone_is_dead = false;
        }

        if everyone_is_dead then should_die = true;
    }
}

draw :: (using particle_system: Particle_System) {
    scale := screen_pixel_zoom();
    glPointSize(xx scale);

    glBindVertexArray(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);

    shader := use_basic_shader();

    model := Matrix4_Identity;
    set_mat4(shader, "model", model);

    //set_vec4(shader, "color", white);
    //glDrawArrays(GL_POINTS, 0, xx vbo_data.count);

    for particle, index: particles {
        if particle.dead then continue;
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
    acceleration : Vector2;
    lifetime : float;

    t : float;
    dead : bool;
}

update :: (using particle : *Particle, dt: float) {
    if dead then return;

    position += velocity * dt;
    velocity += acceleration * dt;

    t += dt;
}


////////////////////////////////////////////////////////////////////////////////
make_dust_cloud :: (at: Pair) -> *Particle_System
{
    dust_cloud : *Particle_System = xx new_entity(.PARTICLE_SYSTEM);
    {
        using dust_cloud;

        position = at;

        one_shot = true;
        lifetime_min = 0.5;
        lifetime_max = 1.5;
        initial_velocity_min = .{-10, 5};
        initial_velocity_max = .{10, 10};
        initial_acceleration_min = .{0, -10};
        initial_acceleration_max = .{0, -15};

        set_count(dust_cloud, 30);

        custom_initializer = dustcloud_particle_initializer;

        initialize(dust_cloud);
    }

    return dust_cloud;
}
