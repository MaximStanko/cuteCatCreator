extends DirectionalLight3D

@export var day_length: float = 180.0

@export var arc_axis: Vector3 = Vector3(1.0, 0.0, 0.25)

@export var running: bool = true

func _process(delta: float) -> void:
	if not running or day_length <= 0.0:
		return
	var speed := TAU / day_length
	rotate(arc_axis.normalized(), speed * delta * 10) # * 10 geschwindigkeit zum testen
