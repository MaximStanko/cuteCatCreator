shader_type spatial;
render_mode cull_back;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D foam_tex : filter_linear_mipmap, repeat_enable, hint_default_black;

// so viele juicy parameter!
uniform vec3 shallow_color : source_color = vec3(0.27, 0.74, 0.86);
uniform vec3 deep_color    : source_color = vec3(0.04, 0.28, 0.55);
uniform vec3 foam_color    : source_color = vec3(0.95, 1.0, 1.0);

uniform float depth_fade  : hint_range(0.05, 10.0) = 1.6;
uniform float color_bands : hint_range(1.0, 6.0) = 3.0;
uniform float water_opacity   : hint_range(0.0, 1.0) = 0.9;
uniform float surface_opacity : hint_range(0.0, 1.0) = 0.4;

uniform float wave_height : hint_range(0.0, 1.0) = 0.06;
uniform float wave_scale  : hint_range(0.1, 8.0) = 1.0;
uniform float wave_speed  : hint_range(0.0, 2.0) = 0.24;

uniform float foam_scale     : hint_range(0.005, 0.5) = 0.05;
uniform float foam_scale2    : hint_range(0.005, 0.5) = 0.028;
uniform float foam_speed     : hint_range(0.0, 0.2)   = 0.015;
uniform float foam_warp      : hint_range(0.0, 1.0)   = 0.15;
uniform float foam_threshold : hint_range(0.0, 1.0)   = 0.3;
uniform float foam_softness  : hint_range(0.01, 0.8)  = 0.35;
uniform float foam_aa        : hint_range(0.0, 8.0)   = 2.5;
uniform float foam_secondary : hint_range(0.0, 1.0)   = 0.5;
uniform float foam_glow      : hint_range(0.0, 1.0)   = 0.1;
uniform float ambient_lift   : hint_range(0.0, 0.5)   = 0.06;

uniform float day_factor    : hint_range(0.0, 1.0) = 1.0;
uniform float night_emission : hint_range(0.0, 1.0) = 0.12;

uniform float spec_power     : hint_range(1.0, 128.0) = 24.0;
uniform float spec_threshold : hint_range(0.0, 1.0)   = 0.5;
uniform float spec_softness  : hint_range(0.0, 0.3)   = 0.04;
uniform float spec_strength  : hint_range(0.0, 4.0)   = 1.3;

vec2 hash22(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return normalize(fract(sin(p) * 43758.5453) * 2.0 - 1.0);
}

float perlin(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

	float d00 = dot(hash22(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0));
	float d10 = dot(hash22(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
	float d01 = dot(hash22(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
	float d11 = dot(hash22(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
	return mix(mix(d00, d10, u.x), mix(d01, d11, u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	mat2 m = mat2(vec2(0.80, 0.60), vec2(-0.60, 0.80));
	for (int i = 0; i < 3; i++) {
		v += a * perlin(p);
		p = m * p * 2.0;
		a *= 0.5;
	}
	return v;
}

float wave_h(vec2 p, float t) {
	float h = fbm(p * wave_scale + vec2(t * 0.20, t * 0.13));
	h += 0.5 * fbm(p * wave_scale * 2.1 + vec2(-t * 0.17, t * 0.23));
	return h;
}

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float t = TIME * wave_speed;
	VERTEX.y += wave_h(world_pos.xz, t) * wave_height;
}

void fragment() {
	float t = TIME * wave_speed;

	float e = 0.15;
	float h  = wave_h(world_pos.xz, t);
	float hx = wave_h(world_pos.xz + vec2(e, 0.0), t);
	float hz = wave_h(world_pos.xz + vec2(0.0, e), t);
	vec3 world_n = normalize(vec3(-(hx - h) / e * wave_height, 1.0, -(hz - h) / e * wave_height));
	NORMAL = normalize((VIEW_MATRIX * vec4(world_n, 0.0)).xyz);

	float depth_raw = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth_raw);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float water_depth = max(-view.z - (-VERTEX.z), 0.0);
	float depth_t = 1.0 - exp(-water_depth / depth_fade);

	float bands = max(color_bands, 1.0);
	float depth_band = clamp(floor(depth_t * bands) / max(bands - 1.0, 1.0), 0.0, 1.0);
	vec3 water = mix(shallow_color, deep_color, depth_band);

	float tt = TIME;
	vec2 base = world_pos.xz;
	vec2 warp = vec2(fbm(base * 0.25 + tt * 0.04),
					 fbm(base * 0.25 + 11.3 - tt * 0.05)) * foam_warp;
	vec2 drift = vec2(tt * foam_speed, tt * foam_speed * 0.6);
	mat2 rot = mat2(vec2(0.866, 0.5), vec2(-0.5, 0.866)); 
	vec2 uvA = base * foam_scale + warp + drift;
	vec2 uvB = (rot * base) * foam_scale2 + warp * 0.7 - drift * 0.5;

	float fa = texture(foam_tex, uvA).r;
	float fb = texture(foam_tex, uvB).r;
	float foam_raw = max(fa, fb * foam_secondary);

	float hw = foam_softness * 0.5 + length(fwidth(uvA)) * foam_aa;
	float foam = smoothstep(foam_threshold - hw, foam_threshold + hw, foam_raw);

	vec3 col = mix(water, foam_color, foam);

	ALBEDO = col;
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
	float emit_scale = mix(night_emission, 1.0, day_factor);
	EMISSION = (col * ambient_lift + foam_color * foam * foam_glow) * emit_scale;
	ALPHA = clamp(max(mix(surface_opacity, water_opacity, depth_t), foam), 0.0, 1.0);
}

void light() {
	float ndl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ATTENUATION * ndl;

	vec3 H = normalize(LIGHT + VIEW);
	float ndh = clamp(dot(NORMAL, H), 0.0, 1.0);
	float spec = pow(ndh, spec_power);
	spec = smoothstep(spec_threshold, spec_threshold + spec_softness, spec);
	float foam_mask = 1.0 - smoothstep(0.55, 0.85, dot(ALBEDO, vec3(0.3333)));

	vec3 light_world = normalize((INV_VIEW_MATRIX * vec4(LIGHT, 0.0)).xyz);
	float above_horizon = smoothstep(0.0, 0.12, light_world.y);

	SPECULAR_LIGHT += spec * spec_strength * foam_mask * above_horizon * LIGHT_COLOR * ATTENUATION;
}
