shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float gray_level : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 bg = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Calculate grayscale average
    float avg = (bg.r + bg.g + bg.b) / 3.0;

    vec3 grayscale_color = vec3(avg);
    vec3 final_color = mix(bg.rgb, grayscale_color, gray_level);

    COLOR = vec4(final_color, bg.a);
}
