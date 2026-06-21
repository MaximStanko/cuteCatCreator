shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

uniform float day_factor : hint_range(0.0, 1.0) = 1.0;
uniform float golden_factor : hint_range(0.0, 1.0) = 0.0;

uniform float warmth : hint_range(0.0, 1.0) = 0.35;
uniform float saturation : hint_range(0.0, 2.0) = 1.12;
uniform float contrast : hint_range(0.5, 1.5) = 1.04;
uniform float lift : hint_range(0.0, 0.2) = 0.02;
uniform float vignette : hint_range(0.0, 1.5) = 0.4;
uniform float vignette_warmth : hint_range(0.0, 1.0) = 0.5;

uniform vec3 day_shadow_tint : source_color = vec3(0.97, 0.86, 0.72);
uniform vec3 day_highlight_tint : source_color = vec3(1.0, 0.94, 0.82);
uniform vec3 night_shadow_tint : source_color = vec3(0.46, 0.55, 0.80);
uniform vec3 night_highlight_tint : source_color = vec3(0.70, 0.80, 1.0);
uniform vec3 golden_tint : source_color = vec3(1.0, 0.74, 0.46);

uniform float night_exposure : hint_range(0.0, 1.0) = 0.55;
uniform float night_desat : hint_range(0.0, 1.0) = 0.78;

const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);

void fragment() {
	vec3 col = texture(screen_tex, SCREEN_UV).rgb;

	vec3 shadow_tint = mix(night_shadow_tint, day_shadow_tint, day_factor);
	vec3 highlight_tint = mix(night_highlight_tint, day_highlight_tint, day_factor);
	shadow_tint = mix(shadow_tint, golden_tint, golden_factor * 0.6);
	highlight_tint = mix(highlight_tint, golden_tint, golden_factor * 0.35);

	float warmth_tod = clamp(warmth * mix(0.4, 1.0, day_factor) + golden_factor * 0.35, 0.0, 1.0);

	float lum = dot(col, LUMA);

	col.r *= 1.0 + warmth_tod * 0.10;
	col.b *= 1.0 - warmth_tod * 0.12;

	vec3 toned = mix(col * shadow_tint, col * highlight_tint, smoothstep(0.0, 1.0, lum));
	col = mix(col, toned, warmth_tod);

	col *= mix(night_exposure, 1.0, day_factor);

	col = col * (1.0 - lift) + lift;

	col = (col - 0.5) * contrast + 0.5;

	float sat_tod = saturation * mix(night_desat, 1.0, day_factor);
	col = mix(vec3(dot(col, LUMA)), col, sat_tod);

	float vig_amt = vignette * mix(1.6, 1.0, day_factor);
	vec2 d = SCREEN_UV - 0.5;
	float vig = clamp(1.0 - vig_amt * dot(d, d) * 2.4, 0.0, 1.0);
	vec3 vig_warm = vec3(vig) * vec3(1.0, 0.85, 0.6);
	vec3 vig_cool = vec3(vig) * vec3(0.6, 0.72, 1.0);
	vec3 vig_tint = mix(vig_cool, vig_warm, day_factor);
	vec3 vig_col = mix(vec3(vig), vig_tint, vignette_warmth);
	col *= vig_col;

	COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
}
