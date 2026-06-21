extends MeshInstance3D

signal vertex_pressed
signal item_rotated
signal vertex_hovered
signal vertex_unhovered

@export var vertex_index: int
@onready var collider: CollisionShape3D = get_child(0).get_child(0)

func _on_area_3d_mouse_entered() -> void:
	vertex_hovered.emit()
	collider.shape.radius = 0.13

func _on_area_3d_mouse_exited() -> void:
	vertex_unhovered.emit()
	collider.shape.radius = 0.1

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("pressed")
			vertex_pressed.emit()
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			item_rotated.emit()
