// Dayne
// Entity
// September 2024

Entity :: struct {
    Kind :: enum {
        TEST;
        GUY;
        PARTICLE_SYSTEM;
    }
    kind : Kind;        @NoSerialize

    z_index     : int;

    id          : int;  @NoSerialize
    should_die  : bool; @NoSerialize

    debug: struct {
        unique_color: Color;
    } @NoSerialize
}

next_id := 0;
new_entity :: (kind : Entity.Kind) -> *Entity {
    new_entity : *Entity;

    if #complete kind == {
        case .TEST;             new_entity = xx New(Test);
        case .GUY;              new_entity = xx New(Guy);
        case .PARTICLE_SYSTEM;  new_entity = xx New(Particle_System);
    }

    initialize(new_entity);

    new_entity.id = next_id;
    next_id += 1;

    return new_entity;
}


initialize :: (entity: *Entity) {
    if #complete entity.kind == {
        case .TEST;             initialize(cast(*Test)entity);
        case .GUY;              initialize(cast(*Guy)entity);
        case .PARTICLE_SYSTEM;  initialize(cast(*Particle_System)entity);
    }


    entity.debug.unique_color = random_color();
}

update :: (entity: *Entity, dt: float) {
    if #complete entity.kind == {
        case .TEST;             update(cast(*Test)entity, dt);
        case .GUY;              update(cast(*Guy)entity, dt);
        case .PARTICLE_SYSTEM;  update(cast(*Particle_System)entity, dt);
    }
}

draw :: (entity: *Entity) {
    if #complete entity.kind == {
        case .TEST;             draw(cast(*Test)entity);
        case .GUY;              draw(cast(*Guy)entity);
        case .PARTICLE_SYSTEM;  draw(cast(*Particle_System)entity);
    }
}

draw_debug :: (entity: *Entity) {
    if #complete entity.kind == {
        case .TEST;             ;
        case .GUY;              draw_debug(cast(*Guy)entity);
        case .PARTICLE_SYSTEM;  ;
    }
}



////////////////////////////////////////////////////////////////////////////////

world_space_to_screen_pixel :: (x: int, y: int) -> pixel: Pair {
    pixel: Pair;

    pixel.x = x;
    pixel.y = y;

    // Camera Transform
    {
        pixel -= game.camera;
    }

    return pixel;
}
