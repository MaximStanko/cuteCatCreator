extends CharacterBody3D


const SPEED = 7.0
const JUMP_VELOCITY = 4.5

@export var turn_speed: float = 12.0
@export var model_forward_offset: float = 0.0

@onready var camera: Camera3D = $SpringArm3D/Camera3D
@onready var model: Node3D = $Mage


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var camera_forward := -camera.global_basis.z
	var camera_right := camera.global_basis.x
	camera_forward.y = 0.0
	camera_right.y = 0.0
	camera_forward = camera_forward.normalized()
	camera_right = camera_right.normalized()

	var direction := (camera_right * input_dir.x - camera_forward * input_dir.y).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		var target_rotation := atan2(direction.x, direction.z) + model_forward_offset
		model.rotation.y = lerp_angle(model.rotation.y, target_rotation, turn_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
