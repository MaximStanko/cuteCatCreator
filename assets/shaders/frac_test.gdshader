shader_type canvas_item;


uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

uniform float warmth : hint_range(0.0, 1.0) = 0.35;
uniform vec3 shadow_tint : source_color = vec3(0.97, 0.86, 0.72);
uniform vec3 highlight_tint : source_color = vec3(1.0, 0.94, 0.82);
uniform float saturation : hint_range(0.0, 2.0) = 1.12;
uniform float contrast : hint_range(0.5, 1.5) = 1.04;
uniform float lift : hint_range(0.0, 0.2) = 0.02;
uniform float vignette : hint_range(0.0, 1.5) = 0.4;
uniform float vignette_warmth : hint_range(0.0, 1.0) = 0.5;

const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);

void fragment() {
	if (true) { // toggle
		vec3 col = texture(screen_tex, SCREEN_UV).rgb;
		float lum = dot(col, LUMA);

		col.r *= 1.0 + warmth * 0.10;
		col.b *= 1.0 - warmth * 0.12;

		vec3 toned = mix(col * shadow_tint, col * highlight_tint, smoothstep(0.0, 1.0, lum));
		col = mix(col, toned, warmth);

		col = col * (1.0 - lift) + lift;

		col = (col - 0.5) * contrast + 0.5;

		col = mix(vec3(dot(col, LUMA)), col, saturation);

		vec2 d = SCREEN_UV - 0.5;
		float vig = clamp(1.0 - vignette * dot(d, d) * 2.4, 0.0, 1.0);
		vec3 vig_col = mix(vec3(vig), vec3(vig) * vec3(1.0, 0.85, 0.6), vignette_warmth);
		col *= vig_col;

		COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
	} else {
		COLOR = texture(screen_tex, SCREEN_UV).rgba;
	}
	
}
