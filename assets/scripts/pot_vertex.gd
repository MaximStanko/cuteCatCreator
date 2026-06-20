extends MeshInstance3D

signal vertex_pressed
signal vertex_hovered
signal vertex_unhovered

@export var vertex_index: int

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			vertex_pressed.emit()

func _on_area_3d_mouse_entered() -> void:
	vertex_hovered.emit()

func _on_area_3d_mouse_exited() -> void:
	vertex_unhovered.emit()
