// Dayne
// OpenGL Shaders
// Alex Hartford
// February 2024

use_sprite_shader :: () -> Shader {
    shader := graphics_context.sprite_shader;
    use_shader(shader);

    orthographic := orthographic_projection_matrix(0, 1, 0, 1, -1, 1);
    set_mat4(shader, "projection", orthographic);

    return shader;
}

use_text_shader :: () -> Shader {
    shader := graphics_context.text_shader;
    use_shader(shader);

    orthographic := orthographic_projection_matrix(0, xx PIXEL_WIDTH, 0, xx PIXEL_HEIGHT, -1, 1);
    set_mat4(shader, "projection", orthographic);

    return shader;
}

use_basic_shader :: () -> Shader {
    shader := graphics_context.basic_shader;
    use_shader(shader);

    orthographic := orthographic_projection_matrix(0, 1, 0, 1, -1, 1);
    set_mat4(shader, "projection", orthographic);

    return shader;
}

//
//
//

Shader :: GLuint;

use_shader :: (shader : Shader) { glUseProgram(shader); }
disable_shaders :: () { glUseProgram(0); }

make_shader :: (vertex_filename: string, fragment_filename: string) -> Shader
{
    vs_text, vertex_success := read_entire_file(tprint("%/%", shaders_path, vertex_filename), log_errors = false);
    defer free(vs_text.data);
    if !vertex_success {
        log_error("Could not read vertex shader: %", vertex_filename);
        return 0;
    }

    fs_text, fragment_success := read_entire_file(tprint("%/%", shaders_path, fragment_filename), log_errors = false);
    defer free(fs_text.data);
    if !fragment_success {
        log_error("Could not read fragment shader: %", fragment_filename);
        return 0;
    }

    shader, compiled := create_shader_program(vs_text, fs_text);
    return shader;
}


// ======================= Simplified uniform interface ========================
set_bool :: (shader : Shader, name: string, value: bool) {
    glUniform1i(glGetUniformLocation(shader, name.data), cast(GLint)value);
}
set_int :: (shader : Shader, name: string, value: int) {
    glUniform1i(glGetUniformLocation(shader, name.data), cast(GLint)value);
}
set_float :: (shader : Shader, name: string, value: float) {
    glUniform1f(glGetUniformLocation(shader, name.data), value);
}
set_vec2 :: (shader : Shader, name: string, value: Vector2) {
    glUniform2fv(glGetUniformLocation(shader, name.data), 1, cast(*float)*value);
}
set_vec3 :: (shader : Shader, name: string, value: Vector3) {
    glUniform3fv(glGetUniformLocation(shader, name.data), 1, cast(*float)*value);
}
set_vec4 :: (shader : Shader, name: string, value: Vector4) {
    glUniform4fv(glGetUniformLocation(shader, name.data), 1, cast(*float)*value);
}
set_mat4 :: (shader : Shader, name: string, value: Matrix4) {
    glUniformMatrix4fv(glGetUniformLocation(shader, name.data), 1, GL_TRUE, *value.coef[0][0]);
}

#scope_file
// =============================================================================
create_shader_program :: (vertex_source: string, fragment_source: string) -> GLuint, bool
{
	check_compile_errors :: (shader: GLuint) -> bool, info_log: string
	{
		success : s32;
		glGetShaderiv(shader, GL_COMPILE_STATUS, *success);
		if !success
		{
			info_len : s32;
			glGetShaderiv(shader, GL_INFO_LOG_LENGTH, *info_len);
			info_data := cast(*u8)alloc(info_len,, temp);
			glGetShaderInfoLog(shader, xx info_len, xx *info_len, info_data);
			result : string;
			result.data = info_data;
			result.count = info_len;

			return false, result;
		}

		return true, "";
	}

	check_link_errors :: (program: GLuint) -> bool, info_log: string
	{
		success : s32;
		glGetProgramiv(program, GL_LINK_STATUS, *success);
		if !success
		{
			info_len : s32;
			glGetProgramiv(program, GL_INFO_LOG_LENGTH, *info_len);
			info_data := cast(*u8)alloc(info_len,, temp);
			glGetProgramInfoLog(program, xx info_len, xx *info_len, info_data);
			result : string;
			result.data = info_data;
			result.count = info_len;

			return false, result;
		}

		return true, "";
	}

	// OpenGL requires us to create at least a vertex shader and a
	// fragment shader, to create a shader program that it can execute.
	vs := glCreateShader(GL_VERTEX_SHADER);
	defer glDeleteShader(vs);
	glShaderSource(vs, 1, *vertex_source.data, null);
	glCompileShader(vs);
	ok, info_log := check_compile_errors(vs);
	if !ok
	{
		log_error("Could not compile vertex shader: %", info_log);
		return 0, false;
	}
	
	fs := glCreateShader(GL_FRAGMENT_SHADER);
	defer glDeleteShader(fs);
	glShaderSource(fs, 1, *fragment_source.data, null);
	glCompileShader(fs);
	ok, info_log = check_compile_errors(fs);
	if !ok
	{
		log_error("Could not compile fragment shader: %", info_log);
		return 0, false;
	}

	result := glCreateProgram();
	glAttachShader(result, vs);
	glAttachShader(result, fs);
	glLinkProgram(result);
	ok, info_log = check_link_errors(result);
	if !ok
	{
		log_error("Could not link shader program: %", info_log);
		glDeleteProgram(result);
		return 0, false;
	}

	return result, true;
}
