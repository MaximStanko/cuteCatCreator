extends Area3D

var awayName = "name"

var player_inside = false
@onready var _label: Label3D = $Label3D

func _ready() -> void:
	_label.text = "?"

func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		player_inside = true
		_label.text = "!"
		

func _on_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		player_inside = false
		_label.text = awayName
		
func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo() or !player_inside:
		return
	match (event as InputEventKey).physical_keycode:
		KEY_E:
			get_tree().change_scene_to_file("res://scenes/cat_pot_scene.tscn")
			pass
