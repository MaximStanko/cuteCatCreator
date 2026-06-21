extends Node

@export var wind_shader: Shader
@export var target_root: Node3D
@export var wind_strength: float = 0.08
@export var wind_speed: float = 1.5
@export var wind_dir: Vector2 = Vector2(1.0, 0.3)
@export var name_prefixes: PackedStringArray = ["Tree", "Bush"]

func _ready() -> void:
	if wind_shader == null:
		push_warning("wind_setup: no wind_shader assigned")
		return
	var root: Node = target_root if target_root != null else get_parent()
	if root:
		_walk(root)

func _walk(n: Node) -> void:
	if n is MeshInstance3D and _matches(n.name):
		_apply(n)
	for c in n.get_children():
		_walk(c)

func _matches(node_name: String) -> bool:
	for p in name_prefixes:
		if node_name.begins_with(p):
			return true
	return false

func _apply(mi: MeshInstance3D) -> void:
	var tex: Texture2D = null
	var src := mi.get_active_material(0)
	if src is StandardMaterial3D:
		tex = (src as StandardMaterial3D).albedo_texture
	if tex == null:
		return

	var m := ShaderMaterial.new()
	m.shader = wind_shader
	m.set_shader_parameter("tex", tex)
	m.set_shader_parameter("wind_strength", wind_strength)
	m.set_shader_parameter("wind_speed", wind_speed)
	m.set_shader_parameter("wind_dir", wind_dir)
	mi.material_override = m
