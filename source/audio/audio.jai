// Dayne
// Audio
// Alex Hartford
// February 2024

Audio_Context :: struct {
    engine : ma_engine;

    sfx_group       : ma_sound_group;
    music_group     : ma_sound_group;
    ambience_group  : ma_sound_group;

    //
    //

    sounds : [128] ma_sound;

    sfx : Table(string, *ma_sound);
    music : Table(string, *ma_sound);

    current_music : *ma_sound;
    current_ambience : *ma_sound;
}

////////////////////////////////////////////////////////////////////////////////

play_sfx :: (name : string) {
    sound, found := table_find(*audio_context.sfx, name);
    if !found {
        log_error("Couldn't find sound: %\n", name);
        return;
    }

    ma_sound_set_volume(sound, 1.0);
    ma_sound_seek_to_pcm_frame(sound, 0);
    ma_sound_start(sound);
}

play_music :: (name : string) {
    if name == "none" then return;
    sound, found := table_find(*audio_context.music, name);
    if !found {
        log_error("Couldn't find sound: %\n", name);
        return;
    }

    ma_sound_set_looping(sound, xx true);
    ma_sound_set_volume(sound, 1.0);
    ma_sound_seek_to_pcm_frame(sound, 0);
    ma_sound_start(sound);
    audio_context.current_music = sound;
}

stop_music :: () {
    sound := audio_context.current_music;
    if !sound return;

    ma_sound_stop(sound);
    audio_context.current_music = null;
}


//
//

set_sfx_volume :: (desired_volume: float) {
    ma_sound_group_set_volume(*audio_context.sfx_group, desired_volume);
}

set_music_volume :: (desired_volume: float) {
    ma_sound_group_set_volume(*audio_context.music_group, desired_volume);
}


////////////////////////////////////////////////////////////////////////////////
// Loading Sounds
////////////////////////////////////////////////////////////////////////////////

Sound_Kind :: enum #complete {
    SFX;
    MUSIC;
}

load_sfx :: #bake_arguments load_sound(kind=.SFX);
load_music :: #bake_arguments load_sound(kind=.MUSIC);

next_sound_index := 0;

load_sound :: (full_path : string, $kind : Sound_Kind) {
    short_name := path_strip_extension(path_filename(full_path));

    sound_group : *ma_sound_group;
    if kind == {
        case .SFX;      sound_group = *audio_context.sfx_group;
        case .MUSIC;    sound_group = *audio_context.music_group;
    }

    pointer_to_new_sound := *audio_context.sounds[next_sound_index];
    next_sound_index += 1;

    flags : ma_sound_flags;
    flags |= .NO_PITCH;
    flags |= .NO_SPATIALIZATION;
    result := ma_sound_init_from_file(*audio_context.engine, temp_c_string(full_path), cast(u32)flags, sound_group, null, pointer_to_new_sound);
    if result != .MA_SUCCESS {
        log_error("Unable to load sound %.\n", full_path);
        assert(false);
    }

    if kind == {
        case .SFX;      table_add(*audio_context.sfx, copy_string(short_name), pointer_to_new_sound);
        case .MUSIC;    table_add(*audio_context.music, copy_string(short_name), pointer_to_new_sound);
    }
}
