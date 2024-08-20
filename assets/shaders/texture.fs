#version 330 core
layout(location = 0) out vec4 FragColor;

in vec2 texture_coordinates;

uniform sampler2D texture_to_sample;
uniform vec4 color_override;
uniform int use_color_override;

void main()
{
    vec4 override = vec4(color_override.xyz, texture(texture_to_sample, texture_coordinates).a);

    vec4 actual = texture(texture_to_sample, texture_coordinates);

    FragColor = mix(actual, override, use_color_override);

    if (FragColor.a < 0.01) discard;
    FragColor.a = 1.0;
}
