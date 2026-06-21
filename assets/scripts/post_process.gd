extends ColorRect


@export var sun: DirectionalLight3D
@export var blend_speed: float = 2.0

var _day := 1.0
var _golden := 0.0
var _mat: ShaderMaterial

func _ready() -> void:
	_mat = material as ShaderMaterial

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
