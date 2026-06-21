extends DirectionalLight3D

@export var day_length: float = 180.0
@export var arc_axis: Vector3 = Vector3(1.0, 0.0, 0.25)
@export var running: bool = true
const SPEEDUP = 1

var is_day = true

func _ready():
	rotation_degrees = GameManager.sun_location
	rotate(arc_axis.normalized(), PI)

func _process(delta: float) -> void:
	if not running or day_length <= 0.0:
		return
	var speed := TAU / day_length
	rotate(arc_axis.normalized(), speed * delta * SPEEDUP) # * 10 geschwindigkeit zum testen
	var new_time = GameManager.time + (delta/day_length)
	
	var t = GameManager.time
	var currently_day = t > 124 or t < 34
	if currently_day and not is_day:
		print("sunrise")
		is_day = true
		GameManager.sunrise.emit()
	elif not currently_day and is_day:
		print("sunset")
		is_day = false
		GameManager.sunset.emit()
