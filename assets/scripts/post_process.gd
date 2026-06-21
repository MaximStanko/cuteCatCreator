extends ColorRect


@export var sun: DirectionalLight3D
@export var water: MeshInstance3D
@export var world_env: WorldEnvironment
@export var blend_speed: float = 2.0

var _day := 1.0
var _golden := 0.0
var _mat: ShaderMaterial
var _water_mat: ShaderMaterial
var _env: Environment
var _fog_energy0 := 1.0
var _vol_density0 := 0.015
var _ambient0 := 0.8

@export var night_ambient: float = 0.1 

func _ready() -> void:
	_mat = material as ShaderMaterial
	if water:
		_water_mat = water.get_surface_override_material(0) as ShaderMaterial
	if world_env:
		_env = world_env.environment
		if _env:
			_fog_energy0 = _env.fog_light_energy
			_vol_density0 = _env.volumetric_fog_density
			_ambient0 = _env.ambient_light_energy

func _process(delta: float) -> void:
	if sun == null or _mat == null:
		return

	var light_dir := -sun.global_transform.basis.z
	var elevation := -light_dir.y 

	var target_day := smoothstep(-0.10, 0.22, elevation)
	var horizon := 1.0 - clampf(absf(elevation) / 0.28, 0.0, 1.0)
	var target_golden := horizon * smoothstep(-0.18, 0.04, elevation)

	var t := clampf(blend_speed * delta, 0.0, 1.0)
	_day = lerpf(_day, target_day, t)
	_golden = lerpf(_golden, target_golden, t)

	_mat.set_shader_parameter("day_factor", _day)
	_mat.set_shader_parameter("golden_factor", _golden)

	if _water_mat:
		_water_mat.set_shader_parameter("day_factor", _day)

	if _env:
		_env.fog_light_energy = _fog_energy0 * lerpf(0.15, 1.0, _day)
		_env.ambient_light_energy = _ambient0 * lerpf(night_ambient, 1.0, _day)
