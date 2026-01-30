shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float thickness : hint_range(0.0, 10.0) = 1.0;
uniform bool visible;

void fragment() {
	if (visible) {
	    vec2 size = TEXTURE_PIXEL_SIZE * thickness;
	    vec4 sprite_color = texture(TEXTURE, UV);

	    float alpha = sprite_color.a;
	    alpha += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
	    alpha += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
	    alpha += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
	    alpha += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;

	    vec4 final_color = mix(sprite_color, outline_color, ceil(clamp(alpha, 0.0, 1.0)) - sprite_color.a);
	    COLOR = vec4(final_color.rgb, clamp(alpha, 0.0, 1.0));
	}
}