shader_type canvas_item;

uniform float star_density : hint_range(0.0, 1.0) = 0.5;
uniform float star_brightness : hint_range(0.0, 1.0) = 0.8;
uniform vec4 star_color : source_color = vec4(1.0);

void fragment()
{
    vec2 uv = SCREEN_UV;

    float rnd = fract(
        sin(dot(floor(uv * 500.0), vec2(12.9898, 78.233)))
        * 43758.5453
    );

    float star = step(1.0 - star_density, rnd);

    COLOR = vec4(star_color.rgb * star_brightness, star);
}