// Dayne
// Graphics Primitives
// February 2024

// Pixel
////////////////////////////////////////////////////////////////////////////////

Pixel :: struct {
    position: Vector2;
    vao, vbo: GLuint;
}

get_pixel_ready_for_drawing_with_opengl :: (using pixel: *Pixel, pixel_position: Pair) {
    pixel.position.x = cast(float)pixel_position.x / PIXEL_WIDTH;
    pixel.position.y = cast(float)pixel_position.y / PIXEL_HEIGHT;

	glGenVertexArrays(1, *vao);
	glGenBuffers(1, *vbo);

	glBindVertexArray(vao);
	defer glBindVertexArray(0);

	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	defer glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBufferData(GL_ARRAY_BUFFER, 2 * size_of(float), *position, GL_STATIC_DRAW);

	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, cast(*void)0);
	glEnableVertexAttribArray(0);
}

draw_pixel :: (using pixel: Pixel) {
	glBindVertexArray(vao);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);

	glDrawArrays(GL_POINTS, 0, 1);
}

// Line
////////////////////////////////////////////////////////////////////////////////

Line :: struct {
    points: [2] Vector2;
    vao, vbo: GLuint;
}

get_line_ready_for_drawing_with_opengl :: (using line: *Line, pixel_position_a: Pair, pixel_position_b: Pair) {
    line.points[0].x = cast(float)pixel_position_a.x / PIXEL_WIDTH;
    line.points[0].y = cast(float)pixel_position_a.y / PIXEL_HEIGHT;

    line.points[1].x = cast(float)pixel_position_b.x / PIXEL_WIDTH;
    line.points[1].y = cast(float)pixel_position_b.y / PIXEL_HEIGHT;

	glGenVertexArrays(1, *vao);
	glGenBuffers(1, *vbo);

	glBindVertexArray(vao);
	defer glBindVertexArray(0);

	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	defer glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBufferData(GL_ARRAY_BUFFER, points.count * 2 * size_of(float), *points[0], GL_STATIC_DRAW);

	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, cast(*void)0);
	glEnableVertexAttribArray(0);
}

draw_line :: (using line: Line) {
	glBindVertexArray(vao);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);

	glDrawArrays(GL_LINES, 0, 2);
}



// Quads
////////////////////////////////////////////////////////////////////////////////

Quad :: struct {
    points := float.[0, 0,
                     0, 1,
                     1, 1,
                     1, 0];
    indices:= u32.[0, 1, 2,
                   0, 2, 3];
    vao, vbo, ibo : GLuint;
}

initialize_quad_rendering_objects :: (using quad : *Quad) {
	glGenVertexArrays(1, *vao);
	glGenBuffers(1, *vbo);
	glGenBuffers(1, *ibo);

	glBindVertexArray(vao);
	defer glBindVertexArray(0);

	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	defer glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBufferData(GL_ARRAY_BUFFER, size_of(float) * points.count, points.data, GL_STATIC_DRAW);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
	defer glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, size_of(u32) * indices.count, indices.data, GL_STATIC_DRAW);

	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * size_of(float), cast(*void)0);
	glEnableVertexAttribArray(0);
}

draw_quad :: (using quad: Quad) {
	glBindVertexArray(vao);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);

	glDrawElements(GL_TRIANGLES, cast(u32)indices.count, GL_UNSIGNED_INT, null);
}

draw_colored_quad :: (x: int, y: int, width: int, height: int, color := white) {
    shader := use_basic_shader();

    model := Matrix4_Identity;
    translation_vector := Vector3.{cast(float)x / PIXEL_WIDTH, cast(float)y / PIXEL_HEIGHT, 0.0};
    scale_vector := Vector3.{cast(float)width / PIXEL_WIDTH, cast(float)height / PIXEL_HEIGHT, 1.0};

    translate(*model, translation_vector);
    scale(*model, scale_vector);
    set_mat4(shader, "model", model);

    set_vec4(shader, "color", color);

    draw_quad(graphics_context.quad);
}
