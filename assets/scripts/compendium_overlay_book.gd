extends Node3D

func _ready() -> void:
	GameManager.update_compendium.connect(update)

func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		self.visible = false

func update():
	for shape in Inventory.found.keys():
		if Inventory.is_found(shape):
			
