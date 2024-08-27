// Dayne
// Entity
// August 2024

Entity :: struct {
    kind : Kind;
    Kind :: enum {
        GUY;
    }

    id : int;

    // Simulation
    using actor : Actor;
    velocity    : Vector2;

    should_die : bool;

    // Appearance
    sprite : int;
    frame : int = 0;
    facing_left : bool;

    z_index  : int;

    // Debugging
    debug_color : Color;
}

update :: (entity: *Entity, dt: float) {
    // Determine Velocity
    {
        // Apply AI
        if entity.kind == {
            case .GUY;
                guy := cast(*Guy)entity;

                something_new := update(*guy.ai, dt);

                if something_new {
                    apply_ai_to_guy(guy, guy.ai);
                }
        }
    }

    // Move Entity
    {
        amount_to_move := entity.velocity * dt;

        collided_x := move_x(entity, amount_to_move.x, null);
        if collided_x then entity.velocity.x = -1 * entity.velocity.x;

        collided_y := move_y(entity, amount_to_move.y, null);
        if collided_y then entity.velocity.y = -1 * entity.velocity.y;

        // The Tank
        {
            ENTITY_TILE_SIZE :: 16; // TODO: What about the sharks???
            extents := game.level.pixel_extents;

            collided_x := (entity.x < extents.x)
                       || (entity.x + entity.width > extents.width)
            ;
            collided_y := (entity.y < extents.y)
                       || (entity.y + entity.height > extents.height)
            ;

            if collided_x {
                entity.x = clamp(entity.x, xx extents.x, xx (extents.x + extents.width - entity.width));
                entity.x_remainder = 0.0;
                entity.velocity.x = -1 * entity.velocity.x;
            }
            if collided_y {
                entity.y = clamp(entity.y, xx extents.y, xx (extents.y + extents.height - entity.height));
                entity.y_remainder = 0.0;
                entity.velocity.y = -1 * entity.velocity.y;
            }
        }
    }

    // Update Visuals
    if entity.kind == {
        case .GUY;
            guy := cast(*Guy)entity;
            update_visuals(guy, dt);
    }
}


next_id := 0;
new_entity :: (entities : *[..] *Entity, kind : Entity.Kind) -> *Entity {
    new_entity : *Entity;

    if #complete kind == {
        case .GUY;
            new_entity = xx New(Guy);
    }

    new_entity.id = next_id;
    next_id += 1;

    new_entity.debug_color = get_random_color();

    array_add(entities, new_entity);

    return new_entity;
}

// Utilities

get_position :: (entity: Entity) -> Vector2 {
    return Vector2.{entity.x + entity.x_remainder, entity.y + entity.y_remainder};
}
