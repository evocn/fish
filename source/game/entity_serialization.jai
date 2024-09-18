// Dayne
// Entity Serialization
// September 2024

// This code is using reflection and metaprogramming to write serialization code for structs.
// We leverage this to not have to write new serialization logic every time we add a field to a struct.
// This approach still is lacking in numerous ways.
// Due to the strictness of casting, I still seem to have to add new entries when adding a new entity kind.
// Plus this code is weird, and I don't like it.
// In any case, this works for now, and we can change it later if the spirit moves us

save_entities :: (entities : [..] *Entity, filename : string) -> success : bool {
    builder : String_Builder;
    defer free_buffers(*builder);

    print_to_builder(*builder, "[%] # Version\n", VERSION);

    for entity : entities {
        append(*builder, "\n");

        serialize(entity.kind, "Kind", *builder);

        success : bool;
        if #complete entity.kind == {
            case .TEST;             success = serialize_structure((cast(*Test)entity).*, *builder);
            case .GUY;              success = serialize_structure((cast(*Guy)entity).*, *builder);
            case .PARTICLE_SYSTEM;  success = serialize_structure((cast(*Particle_System)entity).*, *builder);
        }

        if !success return false;
    }
    full_path := tprint("%/%.entities", data_path, filename);
    write_entire_file(full_path, *builder);

    log("Saved entities to \"%\".", full_path);

    return true;
}

// Assumption is that entity pool allocator is on the context.
load_entities :: (entities : *[..] *Entity, filename : string) -> success : bool {
    handler : Text_File_Handler;
    defer deinit(*handler);

    full_path := tprint("%/%.entities", data_path, filename);

    start_file(*handler, filename, full_path, optional = false);
    if handler.failed return false;

    if handler.version != VERSION
        return error_out(handler, "Error: out of sync version number. This file has version number %, while the program expects %.\n", handler.version, VERSION);

    array_reset(entities);

    while handler.file_data {
        new_entity, success := get_next_entity(*handler);
        if !success log_error("File Handler problem with %.\n", full_path);
        array_add(entities, new_entity);
    }

    log("Loaded entities from \"%\".", full_path);

    return true;
}

////////////////////////////////////////////////////////////////////////////////
// %1          = member name
// type_of(%1) = member type
for_each_member :: ($T: Type, format: string) -> string
{
    builder: String_Builder;
    defer free_buffers(*builder);

    struct_info := cast(*Type_Info_Struct) T;
    assert(struct_info.type == Type_Info_Tag.STRUCT);

    for member : struct_info.members 
    {
        if member.flags & .CONSTANT continue;

        for note: member.notes {
            if note == "NoSerialize" then continue member;
        }

        print_to_builder(*builder, format, member.name);
    }

    return builder_to_string(*builder);
}

serialize_structure :: (s: $T, builder: *String_Builder) -> success: bool
{
    #insert #run for_each_member(T, "if !serialize(s.%1, \"%1\", builder) return false;\n" );
    return true;
}

////////////////////////////////////////////////////////////////////////////////
// Definitions for how we want to serialize things.

serialize  :: (to_serialize: int, name : string, builder: *String_Builder) -> success: bool { 
    print_to_builder(builder, "%", to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true; 
}
serialize  :: (to_serialize: u64, name : string, builder: *String_Builder) -> success: bool { 
    print_to_builder(builder, "%", to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true; 
}
serialize  :: (to_serialize: float, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: bool, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: string, name : string, builder: *String_Builder) -> success: bool { 
    if !to_serialize
        print_to_builder(builder, "!");
    else
        print_to_builder(builder, "%", to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: Vector2, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "% %", to_serialize.x, to_serialize.y);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: Vector4, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "% % % %", to_serialize.x, to_serialize.y, to_serialize.z, to_serialize.w);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}

//
//

serialize  :: (to_serialize: Entity, name := "", builder: *String_Builder) -> success: bool { 
    success := serialize_structure(to_serialize, builder);
    return success;
}

serialize  :: (to_serialize: Entity.Kind, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# % (%)", name, to_serialize);
    append(builder, "\n");
    return true;
}

serialize  :: (to_serialize: AI_Controller, name := "", builder: *String_Builder) -> success: bool { 
    success := serialize_structure(to_serialize, builder);
    return success;
}

serialize  :: (to_serialize: Actor, name := "", builder: *String_Builder) -> success: bool { 
    success := serialize_structure(to_serialize, builder);
    return success;
}

serialize  :: (to_serialize: Solid, name := "", builder: *String_Builder) -> success: bool { 
    success := serialize_structure(to_serialize, builder);
    return success;
}

serialize  :: (to_serialize: Collider, name := "", builder: *String_Builder) -> success: bool { 
    success := serialize_structure(to_serialize, builder);
    return success;
}

serialize  :: (to_serialize: Animation_Integer, name := "", builder: *String_Builder) -> success: bool { 
    append(builder, "\n");
    success := serialize_structure(to_serialize, builder);
    return success;
}

serialize  :: (to_serialize: AI_Controller.State, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}

serialize  :: (to_serialize: Guy_Animation_State, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}

serialize  :: (to_serialize: [..] Animation_Integer.Keyframe, name := "", builder: *String_Builder) -> success: bool { 
    success : bool;
    serialize(to_serialize.count, "Keyframe count", builder);
    for keyframe : to_serialize {
        success = serialize_structure(keyframe, builder);
        if !success return false;
    }

    return success;
}

//
//
//

get_next_entity :: (handler : *Text_File_Handler) -> entity: *Entity, success: bool {
    kind_int, is_another_entity_to_get := parse_int(handler);
    if !is_another_entity_to_get return null, false;

    kind := cast(Entity.Kind)kind_int;

    entity := new_entity(kind);
    success : bool;

    if #complete kind == {
        case .TEST;             success = unserialize_structure(cast(*Test)entity, handler);
        case .GUY;              success = unserialize_structure(cast(*Guy)entity, handler);
        case .PARTICLE_SYSTEM;  success = unserialize_structure(cast(*Particle_System)entity, handler);
    }

    initialize(entity);

    assert(success, "Failed to unserialize entity of kind %\n", kind);

    return entity, success;
}

unserialize_structure :: (s: *$T, handler: *Text_File_Handler) -> success: bool {
    success : bool;
    #insert #run for_each_member(T, "if !unserialize(*s.%1, handler) return false;\n" );
    return true;
}

// Definitions for how we want to unserialize things.
// Think of these not as code, but as a bunch of settings.
//

unserialize  :: (to_unserialize: *int, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_int(handler);
    return success;
}
unserialize  :: (to_unserialize: *u64, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_int(handler, u64);
    return success;
}
unserialize  :: (to_unserialize: *float, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_float(handler);
    return success;
}
unserialize  :: (to_unserialize: *bool, handler : *Text_File_Handler) -> success: bool { 
    b, success := parse_int(handler);
    <<to_unserialize = cast(bool)b;
    return success;
}
unserialize  :: (to_unserialize: *string, handler : *Text_File_Handler) -> success: bool { 
    str, success := parse_string(handler);
    if str == "!" then to_unserialize.* = "";
    else {
        to_unserialize.* = copy_string(str);
    }
    return success;
}
unserialize  :: (to_unserialize: *Vector2, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_vector2(handler);
    return success;
}
unserialize  :: (to_unserialize: *Vector4, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_vector4(handler);
    return success;
}

unserialize  :: (to_unserialize: *Entity, handler: *Text_File_Handler) -> success: bool {
    success := unserialize_structure(to_unserialize, handler);
    return success;
}

unserialize  :: (to_unserialize: *Entity.Kind, handler: *Text_File_Handler) -> success: bool {
    // @NOTE: We parse this separately so we know what kind of entity we're lookin at.
    return true;
}

unserialize  :: (to_unserialize: *AI_Controller, handler: *Text_File_Handler) -> success: bool {
    success := unserialize_structure(to_unserialize, handler);
    return success;
}

unserialize  :: (to_unserialize: *Actor, handler: *Text_File_Handler) -> success: bool {
    success := unserialize_structure(to_unserialize, handler);
    return success;
}

unserialize  :: (to_unserialize: *Solid, handler: *Text_File_Handler) -> success: bool {
    success := unserialize_structure(to_unserialize, handler);
    return success;
}

unserialize  :: (to_unserialize: *Collider, handler: *Text_File_Handler) -> success: bool {
    success := unserialize_structure(to_unserialize, handler);
    return success;
}

unserialize  :: (to_unserialize: *Animation_Integer, handler: *Text_File_Handler) -> success: bool {
    success := unserialize_structure(to_unserialize, handler);
    return success;
}

unserialize  :: (to_unserialize: *AI_Controller.State, handler : *Text_File_Handler) -> success: bool { 
    e, success := parse_int(handler);
    to_unserialize.* = cast(AI_Controller.State)e;
    return success;
}

unserialize  :: (to_unserialize: *Guy_Animation_State, handler : *Text_File_Handler) -> success: bool { 
    e, success := parse_int(handler);
    to_unserialize.* = cast(Guy_Animation_State)e;
    return success;
}

unserialize  :: (to_unserialize: *[..] Animation_Integer.Keyframe, handler: *Text_File_Handler) -> success: bool {
    success : bool;
    count : int;
    unserialize(*count, handler);
    for 0..count-1 {
        new_keyframe := array_add(to_unserialize);
        success = unserialize_structure(new_keyframe, handler);
        if !success return false;
    }

    return success;
}





////////////////////////////////////////////////////////////////////////////////
// Parsing Utils below to fill out the text file handler
////////////////////////////////////////////////////////////////////////////////

error_out :: inline (handler : Text_File_Handler, str : string, args : ..Any) -> bool
{
	error(handler, str, ..args);
	return false;
}

parse_string :: (handler : *Text_File_Handler) -> string, bool
{
	line, ok := consume_next_line(handler);
	if !ok
		return line, error_out(handler, "Unexpected EOF.");
	return line, true;
}

// Parse a line in the format IDENTIFIER INTEGER
parse_ident_and_int_line :: (handler : *Text_File_Handler, expected_ident : string) -> int, bool
{
	line, found := consume_next_line (handler);
	if !found
		return 0, false;
	val : int;
	ok : bool;
	ident, right := break_by_spaces (line);
	if ident != expected_ident
		return 0, error_out (handler, "Expected '%'.", expected_ident);
	val, ok, right = string_to_int (right);
	if !ok
		return 0, error_out (handler, "Expected an integer after '%'.", expected_ident);
	right = trim (right);
	if right.count != 0
		return 0, error_out (handler, "Expected nothing after INTEGER, got %.", right);
	if val < 0
		return 0, error_out (handler, "Expected a positive integer.");
	return val, true;
}

parse_int :: (handler : *Text_File_Handler, $Int_Type := s64) -> Int_Type, bool
#modify {
	info := cast (*Type_Info) Int_Type;
	return info.type == .INTEGER;
}
{
	line, ok := consume_next_line (handler);
	if !ok
		return 0, error_out (handler, "Unexpected EOF.");
	val : s64;
	val, ok, line = string_to_int (line);
	if !ok
		return 0, error_out (handler, "Expected an integer.");
	// @Cleanup: This will fail if the integer is out of bounds, but
	// we probably should check for overflow ourselves
	result := cast (Int_Type) val;
	line = trim_left (line);
	if line.count > 0
		return 0, error_out (handler, "Expected end of line.");
	return result, true;
}

parse_float :: (handler : *Text_File_Handler, $Float_Type := float32) -> Float_Type, bool
#modify {
	info := cast (*Type_Info) Float_Type;
	return info.type == .FLOAT;
}
{
	line, ok := consume_next_line (handler);
	if !ok
		return 0, error_out (handler, "Unexpected EOF.");
	val : float64;
	val, ok, line = string_to_float (line);
	if !ok
		return 0, error_out (handler, "Expected a float.");
	result := cast (Float_Type) val;
	line = trim_left (line);
	if line.count > 0
		return 0, error_out (handler, "Expected end of line.");
	return result, true;
}

// Parse a line in the format INTEGER INTEGER INTEGER ...
parse_int_tuple :: (handler : *Text_File_Handler, $count : int, $Int_Type := s64) -> [count]Int_Type, bool
#modify {
	info := cast (*Type_Info) Int_Type;
	return info.type == .INTEGER;
}
{
	result : [count]Int_Type = ---;
	line, ok := consume_next_line (handler);
	if !ok
		return result, error_out (handler, "Unexpected EOF.");
	for i : 0..count - 1
	{
		val : s64;
		val, ok, line = string_to_int (line);
		if !ok
			return result, error_out (handler, "Expected an integer for component % of % tuple[%].", i, Int_Type, count);
		// @Cleanup: This will fail if the integer is out of bounds, but
		// we probably should check for overflow ourselves
		result[i] = xx val;
		line = trim_left (line);
	}
	if line.count > 0
		return result, error_out (handler, "Expected end of line.");
	return result, true;
}

// Parse a line in the format FLOAT FLOAT FLOAT ...
parse_float_tuple :: (handler : *Text_File_Handler, $count : int) -> [count]float, bool
{
	result : [count]float = ---;
	line, ok := consume_next_line (handler);
	if !ok
		return result, error_out (handler, "Unexpected EOF.");
	for i : 0..count - 1
	{
		result[i], ok, line = string_to_float (line);
		if !ok
			return result, error_out (handler, "Expected a floating point number for component % of float tuple[%], got '%'.", i, count, line);
		line = trim_left (line);
	}
	if line.count > 0
		return result, error_out (handler, "Expected end of line.");
	return result, true;
}

parse_vector2 :: (handler : *Text_File_Handler) -> Vector2, bool
{
	components, ok := parse_float_tuple (handler, 2);
	if !ok
		return .{}, false;
	result : Vector2 = ---;
	result.component = components;
	return result, true;
}

parse_vector4 :: (handler : *Text_File_Handler) -> Vector4, bool
{
	components, ok := parse_float_tuple (handler, 4);
	if !ok
		return .{}, false;
	result : Vector4 = ---;
	result.component = components;
	return result, true;
}
