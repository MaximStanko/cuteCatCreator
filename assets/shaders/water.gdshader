shader_type spatial;
render_mode cull_back, specular_schlick_ggx;


uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

// so viele juicy parameter!
uniform vec3 shallow_color : source_color = vec3(0.34, 0.66, 0.69);
uniform vec3 deep_color : source_color = vec3(0.05, 0.20, 0.33);
uniform float depth_fade : hint_range(0.05, 10.0) = 1.6;
uniform float water_opacity : hint_range(0.0, 1.0) = 0.9;
uniform float surface_opacity : hint_range(0.0, 1.0) = 0.25;

uniform float wave_height : hint_range(0.0, 1.0) = 0.06;
uniform float wave_scale : hint_range(0.1, 8.0) = 1.4;
uniform float wave_speed : hint_range(0.0, 2.0) = 0.35;

uniform float ripple_scale : hint_range(1.0, 40.0) = 12.0;
uniform float ripple_speed : hint_range(0.0, 2.0) = 0.25;
uniform float normal_strength : hint_range(0.0, 1.0) = 0.35;

uniform float water_roughness : hint_range(0.0, 1.0) = 0.04;
uniform float fresnel_power : hint_range(1.0, 8.0) = 5.0;

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
	for (int i = 0; i < 5; i++) {
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
	float t_wave = TIME * wave_speed;
	float t_rip = TIME * ripple_speed;
	float e = 0.15;

	float h = wave_h(world_pos.xz, t_wave);
	float hx = wave_h(world_pos.xz + vec2(e, 0.0), t_wave);
	float hz = wave_h(world_pos.xz + vec2(0.0, e), t_wave);
	vec3 swell_n = vec3(-(hx - h) / e * wave_height, 1.0, -(hz - h) / e * wave_height);

	vec2 ruv = world_pos.xz * ripple_scale;
	vec2 warp = vec2(fbm(ruv * 0.4 + t_rip * 0.15), fbm(ruv * 0.4 + 7.3 - t_rip * 0.12));
	ruv += warp * 3.0;
	vec2 flow = vec2(t_rip, t_rip * 0.6);
	float r = fbm(ruv + flow);
	float rx = fbm(ruv + vec2(0.3, 0.0) + flow) - r;
	float rz = fbm(ruv + vec2(0.0, 0.3) + flow) - r;
	vec3 ripple_n = vec3(-rx, 1.0, -rz);

	vec3 world_n = normalize(mix(swell_n, ripple_n, normal_strength));
	NORMAL = normalize((VIEW_MATRIX * vec4(world_n, 0.0)).xyz);

	float depth_raw = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth_raw);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float water_depth = max(-view.z - (-VERTEX.z), 0.0);
	float depth_t = 1.0 - exp(-water_depth / depth_fade);

	vec3 col = mix(shallow_color, deep_color, depth_t);

	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);

	ALBEDO = col;
	METALLIC = 0.0;
	SPECULAR = 0.5;
	ROUGHNESS = mix(water_roughness, 0.0, fres);
	ALPHA = clamp(mix(surface_opacity, water_opacity, depth_t) + fres * 0.4, 0.0, 1.0);
}
