// Dayne
// Text Rendering
// Alex Hartford
// February 2024

draw_text :: (text: string, x: int, y: int, 
              alignment := Alignment.LEFT,
              progress := -1,
              font : Font_Kind = .MAIN,
              color := white
             )
{
    shader := use_text_shader();

    set_vec4(shader, "color", color);

    the_font : *Font;
    if #complete font == {
        case .MAIN;  the_font = *graphics_context.main_font;
        case .SMALL; the_font = *graphics_context.small_font;
    }

    lines := split(text, "\n",, temp);
    for lines {
        render_text(
            the_font, it,
            cast(float)(x),
            cast(float)(y - (it_index * (the_font.height - 4))),
            alignment = alignment,
            progress = progress,
        );
    }
}

//
//

Font_Kind :: enum #complete {
    MAIN;
    SMALL;
}

Font :: struct {
    characters : Table(u8, Character_Glyph);
    height : int;
    vao, vbo : GLuint;
}

ft : FT_Library;
initialize_freetype :: () {
    if FT_Init_FreeType(*ft) {
        log_error("Could not initialize the Freetype Library.\n");
        assert(false);
    }
}

Alignment :: enum {
    LEFT;
    CENTER;
    RIGHT;
}

render_text :: (font : Font, text : string, x : float, y : float, alignment : Alignment, progress : int)
{
    glActiveTexture(GL_TEXTURE0);
    defer glBindTexture(GL_TEXTURE_2D, 0);

    glBindVertexArray(font.vao);
    defer glBindVertexArray(0);

    total_width : float;
    if alignment == .CENTER || alignment == .RIGHT {
        for cast([] u8)text {
            glyph, found := table_find(*font.characters, it);
            assert(found);

            total_width += glyph.advance >> 6;
        }
    }

    for char : (cast([] u8)text) {
        if progress != -1 && it_index >= progress {
            break;
        }

        glyph, found := table_find(*font.characters, char);
        assert(found);

        xpos : float;
        if alignment == .CENTER
            xpos = floor(x - (total_width / 2.0) + glyph.bearing.x);
        else if alignment == .RIGHT
            xpos = floor(x - total_width + glyph.bearing.x - 1);
        else
            xpos = x + glyph.bearing.x + 1;

        ypos := y - (glyph.size.y - glyph.bearing.y);

        w := glyph.size.x;
        h := glyph.size.y;

        // update VBO for each character
        vertices : [6][4] float = .[
            .[xpos,     ypos + h,   0.0, 0.0],
            .[xpos,     ypos,       0.0, 1.0],
            .[xpos + w, ypos,       1.0, 1.0],
            .[xpos,     ypos + h,   0.0, 0.0],
            .[xpos + w, ypos,       1.0, 1.0],
            .[xpos + w, ypos + h,   1.0, 0.0],
        ];

        glBindTexture(GL_TEXTURE_2D, glyph.id);
        glBindBuffer(GL_ARRAY_BUFFER, font.vbo);
        glBufferSubData(GL_ARRAY_BUFFER, 0, 6 * 4 * size_of(float), vertices.data);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDrawArrays(GL_TRIANGLES, 0, 6);

        // advance cursors for next glyph (note that advance is number of 1/64 pixels)
        x += glyph.advance >> 6; // (2^6 = 64)
    }
}

//
//

Character_Glyph :: struct {
    id      : GLuint;
    size    : Vector2; // Size of glyph
    bearing : Vector2; // Offset from baseline to left/top of glyph
    advance : u64;     // Offset to advance to next glyph
};

initialize_font :: (font: *Font, filename : string, size : u32) {
    face : FT_Face;
    full_path := temp_c_string(tprint("%/%", fonts_path, filename));
    code := FT_New_Face(ft, full_path, 0, *face);
    if code {
        log_error("Freetype failed to load font \"%\": %\n", filename, code);
        assert(false);
    }

    FT_Set_Pixel_Sizes(face, 0, size);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1); // disable byte-alignment restriction

    font.height = size;

    zero : u32; top : u32 = 127;
    for c : zero..top {
        // load character glyph 
        if FT_Load_Char(face, c, FT_LOAD_RENDER) {
            log_error("Freetype failed to load Glyph.\n");
            assert(false);
        }

        // generate texture
        id : GLuint;
        glGenTextures(1, *id);
        glBindTexture(GL_TEXTURE_2D, id);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RED,
            xx face.glyph.bitmap.width, xx face.glyph.bitmap.rows,
            0, GL_RED, GL_UNSIGNED_BYTE, face.glyph.bitmap.buffer);
        // set texture options
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        // now store character for later use
        glyph := Character_Glyph.{
            id,
            Vector2.{xx face.glyph.bitmap.width, xx face.glyph.bitmap.rows},
            Vector2.{xx face.glyph.bitmap_left, xx face.glyph.bitmap_top},
            xx face.glyph.advance.x
        };
        table_add(*font.characters, cast(u8)c, glyph);
    }

    FT_Done_Face(face);

    init_font_rendering_objects(font);
}

init_font_rendering_objects :: (using font : *Font) {
    glGenVertexArrays(1, *vao);
    glGenBuffers(1, *vbo);
    glBindVertexArray(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, size_of(float) * 6 * 4, null, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * size_of(float), cast(*void)0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}
