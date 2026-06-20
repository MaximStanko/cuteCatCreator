extends SpringArm3D

@export var mouse_sensibility: float = 0.005
@export_range(-80.0, -5.0, 0.1, "radians_as_degrees") var min_vertical_angle: float = deg_to_rad(-60.0)
@export_range(-5.0, 20.0, 0.1, "radians_as_degrees") var max_vertical_angle: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rotation.x = clamp(rotation.x, min_vertical_angle, max_vertical_angle)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensibility
		rotation.y = wrapf(rotation.y, 0.0, TAU)
		
		rotation.x -= event.relative.y * mouse_sensibility
		rotation.x = clamp(rotation.x, min_vertical_angle, max_vertical_angle)
