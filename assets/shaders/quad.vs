#version 330 core
layout (location = 0) in vec3 VertexPosition;

out vec2 texture_coordinates;

uniform mat4 model;

void main()
{
    texture_coordinates = VertexPosition.xy;
    gl_Position = model * vec4(VertexPosition, 1.0);
}
