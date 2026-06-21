shader_type spatial;
render_mode cull_back;

uniform sampler2D tex : source_color, filter_linear_mipmap;
uniform float wind_strength : hint_range(0.0, 0.5) = 0.05;
uniform float wind_speed    : hint_range(0.0, 5.0) = 0.5;
uniform vec2  wind_dir = vec2(1.0, 0.3);
uniform float sway_height : hint_range(0.1, 8.0) = 2.5;

void vertex() {
	vec3 wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float phase = TIME * wind_speed + wp.x * 0.35 + wp.z * 0.35;
	float gust = sin(phase) + 0.4 * sin(phase * 2.3 + 1.7);
	float mask = clamp(VERTEX.y / sway_height, 0.0, 1.0);
	mask *= mask;
	vec2 d = normalize(wind_dir + vec2(0.0001));
	VERTEX.x += d.x * gust * wind_strength * mask;
	VERTEX.z += d.y * gust * wind_strength * mask;
}

void fragment() {
	ALBEDO = texture(tex, UV).rgb;
	ROUGHNESS = 1.0;
}
