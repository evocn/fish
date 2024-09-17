// Dayne
// Graphics Drawing Functions
// August 2024


// Entity
draw_tile :: (tile: Tile, place : Pair) {
    screen_position := world_space_to_screen_pixel(place.x, place.y);
    draw_tile_at(tile, screen_position);
}

draw_tile_at :: (tile: Tile, at: Pair) {
    sprite := table_find_pointer(*graphics_context.sheets, "fishes");
    if !sprite {
        log_error("Couldn't load tile spritesheet.\n");
        return;
    }

    draw_sprite(
        sprite,
        index = tile.sprite,
        pixel = at,

        scale_factor = 1,

        horizontal_flip = false,

        use_color_override = false,
    );
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
