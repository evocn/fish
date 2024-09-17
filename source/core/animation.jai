// Dayne
// Animation
// September 2024

Animation_Float :: struct {
    value: *float;

    // Properties
    Keyframe :: struct {
        time    : float;
        value   : float;
    }
    keyframes: [..] Keyframe;

    duration: float;

    easing_function : (float) -> (float) = easing_identity;

    // State
    time    : float;
    active  : bool;
}

animation_float_make :: (value: *float, duration: float, keyframes: ..Animation_Float.Keyframe) -> Animation_Float {
    animation: Animation_Float;

    animation.value = value;
    animation.duration = duration;
    for keyframes {
        array_add(*animation.keyframes, it);
    }

    return animation;
}

restart :: (animation: *Animation_Float) {
    animation.active = true;
    animation.time = 0.0;
    animation.value.* = get_value(animation.*); 
}

update :: (animation: *Animation_Float, dt: float) {
    animation.time += dt;
    if animation.time > animation.duration
        animation.time = animation.time - animation.duration;

    animation.value.* = get_value(animation.*);
}

//

get_value :: (animation: Animation_Float) -> float {
    assert(animation.keyframes.count > 0);

    for keyframe, index : animation.keyframes {
        if keyframe.time > animation.time {
            // Interpolate between this frame and the last one, an amount based on how much past the time the current frame is.
            last_frame := animation.keyframes[index-1].value;
            this_frame := keyframe.value;
            t := keyframe.time - animation.time;

            value := lerp(last_frame, this_frame, animation.easing_function(t));
            return value;
        }
    }

    // If we get here, then the animation time is past the end of the last keyframe.
    // Therefore, we should just freeze on the last keyframe.
    return animation.keyframes[animation.keyframes.count - 1].value;
}



////////////////////////////////////////////////////////////////////////////////
// Integer Animation (For stuff like spritesheets.)
////////////////////////////////////////////////////////////////////////////////

Animation_Integer :: struct {
    value : *int;

    // Properties
    Keyframe :: struct {
        time : float;
        value : int;
    }
    keyframes : [..] Keyframe;

    duration : float;

    // State
    time : float;
    active : bool;
}

animation_integer_make :: (value: *int, duration: float, keyframes: ..Animation_Integer.Keyframe) -> Animation_Integer {
    animation: Animation_Integer;

    animation.value = value;
    animation.duration = duration;
    for keyframes {
        array_add(*animation.keyframes, it);
    }

    return animation;
}

update :: (animation: *Animation_Integer, dt: float) {
    animation.time += dt;
    if animation.time > animation.duration
        animation.time = animation.time - animation.duration;

    animation.value.* = get_value(animation.*);
}

start :: (animation: *Animation_Integer) {
    animation.active = true;
    animation.time = 0.0;
    animation.value.* = get_value(animation.*); 
}

//

get_value :: (animation: Animation_Integer) -> int {
    assert(animation.keyframes.count > 0);

    for animation.keyframes {
        if it.time > animation.time then return animation.keyframes[it_index-1].value;
    }

    return animation.keyframes[animation.keyframes.count-1].value;
}



////////////////////////////////////////////////////////////////////////////////
// Easing Functions
////////////////////////////////////////////////////////////////////////////////

easing_identity :: (t: float) -> float {
    return t;
}

easing_flip :: (t: float) -> float {
    return 1 - t;
}

easing_smooth_start :: (t: float) -> float {
    return t * t * t;
}

easing_smooth_stop :: (t: float) -> float {
    return easing_flip(easing_smooth_start(easing_flip(t)));
}

easing_smooth_start_stop :: (t: float) -> float {
    return lerp(easing_smooth_start(t), easing_smooth_stop(t), t);
}

easing_stair :: (t: float) -> float {
    return cast(float)cast(int)t;
}
