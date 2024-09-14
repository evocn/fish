// Dayne
// Graphics Drawing Functions
// August 2024


// Entity
draw_tile :: (tile: Tile, place : Pair, camera_center : Pair) {
    relative_position_to_camera_center := place - camera_center;
    draw_tile_at(tile, relative_position_to_camera_center);
}

draw_tile_at :: (tile: Tile, at: Pair) {
    draw_sprite(
        graphics_context.spritesheet,
        index = tile.sprite,
        pixel = at,

        scale_factor = 1,

        horizontal_flip = false,

        use_color_override = false,
    );
}

SPRITESHEET_WIDTH :: 16;

draw_entity_at :: (entity: Entity, at: Pair) {
    bottom_left_corner_of_sprite := at  // Bottom left corner of collider
        + .{entity.width / 2, 0}        // Gets us the center bottom of collider
        - .{TILE_SIZE_IN_PIXELS / 2, 0} // Bottom left corner!
    ;

    draw_sprite(
        graphics_context.spritesheet,
        index = (entity.sprite * SPRITESHEET_WIDTH) + entity.frame,
        pixel = bottom_left_corner_of_sprite,

        scale_factor = 1,

        horizontal_flip = entity.facing_left,

        use_color_override = false,

        /*
        use_color_override = true,
        color_override = entity.color,
        */
    );
}

draw_entity :: (entity: Entity) {
    draw_entity_at(entity, to_pair(get_position(entity)));
}

draw_entity :: (entity: Entity, camera_center : Pair) {
    relative_position_to_camera_center := to_pair(get_position(entity)) - camera_center;
    draw_entity_at(entity, relative_position_to_camera_center);
}


// Menu
draw_menu :: (using menu: Menu) {
    k := 10;

    for elements {
        draw_menu_element(it, PIXEL_HEIGHT - (it_index + 1) * k, color=it.usual_color);
    }

    // Draw selected element over it.
    if elements.count {
        hovering := *elements[element_index];
        draw_menu_element(hovering.*, PIXEL_HEIGHT - (element_index + 1) * k, color=hovering.*.hover_color);
    }
}

draw_menu_element :: (using element: *Menu_Element, height : int, color := white) {
    if kind == {
        case .GO;
            using cast(*Menu_Element_Go)element;
            draw_text(name, 1, height, color=color);

        case .CHECKBOX;
            using cast(*Menu_Element_Checkbox)element;
            str := "Off";
            if value.* then str = "On";
            draw_text(tprint("% - %", name, str), 1, height, color=color);

        case .SLIDER;
            using cast(*Menu_Element_Slider)element;
            draw_text(tprint("% - %", name, value.*), 1, height, color=color);
    }
}


// Clock
draw_clock_readout :: () {
    apollo_time := current_time_consensus();
    using time := to_calendar(apollo_time, Time_Zone.LOCAL);

    clock_readout : string;
    {
        am_pm_string : string;
        if hour < 12 {
            am_pm_string = "am";
        }
        else {
            am_pm_string = "pm";
        }

        hour_in_twelve_hour_time := hour;
        if hour_in_twelve_hour_time > 12 {
            hour_in_twelve_hour_time -= 12;
        }

        new_context := context;
        format_int := *new_context.print_style.default_format_int;
        format_int.minimum_digits = 2;

        push_context new_context {
            clock_readout = tprint("%:% %", hour_in_twelve_hour_time, minute, am_pm_string);
        }
    }

    color : Color;
    {
        if hour < 3 {
            color = pink;
        }
        else if hour < 6 {
            color = purple;
        }
        else if hour < 9 {
            color = yellow;
        }
        else if hour < 12 {
            color = green;
        }
        else if hour < 15 {
            color = teal;
        }
        else if hour < 18 {
            color = blue;
        }
        else if hour < 21 {
            color = red;
        }
        else if hour < 24 {
            color = gray;
        }
        else {
            "What the fuck?";
        }
    }

    draw_colored_quad(
        x = 0,
        y = 0,
        width  = 34,
        height = 7,
        color  = black,
    );

    draw_text(
        clock_readout, 
        x = 1,
        y = 1,
        alignment   = Alignment.LEFT,
        progress    = -1,
        font        = .SMALL,
        color       = color,
    );
}


draw :: (collider: Collider, color : Color, outline_color := white) {
    draw_colored_quad(xx collider.x, xx collider.y, xx collider.width, xx collider.height, color=color);
}
