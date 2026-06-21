extends CharacterBody3D


const SPEED = 4.0
const JUMP_VELOCITY = 4.5

@export var fall_respawn_y: float = -10.0
@export var turn_speed: float = 12.0
@export var model_forward_offset: float = 0.0
@export var run_animation: StringName = &"Player Animationen/Rennen"
@export var idle_animation: StringName = &"Player Animationen/Chill"
@export var jump_start_animation: StringName = &"Player Animationen/jump_start"
@export var jump_idle_animation: StringName = &"Player Animationen/jump_idle"
@export var animation_blend_time: float = 0.15

@onready var camera: Camera3D = $SpringArm3D/Camera3D
@onready var model: Node3D = $Mage
@onready var animation_player: AnimationPlayer = $Mage/AnimationPlayer

var start_position: Vector3


func _ready() -> void:#
	global_position = GameManager.player_pos
	rotation_degrees = GameManager.player_rot
	start_position = global_position
	_play_animation(idle_animation)
	GameManager.sunrise.connect(_on_sunrise)
	GameManager.sunset.connect(_on_sunset)

func _physics_process(delta: float) -> void:
	if global_position.y < fall_respawn_y:
		_respawn_at_start()
		return

	var jumped := false

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumped = true

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
		model.global_rotation.y = lerp_angle(model.global_rotation.y, target_rotation, turn_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	var now_on_floor := is_on_floor()
	if jumped:
		_play_animation(jump_start_animation)
	elif not now_on_floor:
		if not _is_animation_playing(jump_start_animation):
			_play_animation(jump_idle_animation)
	else:
		if direction:
			_play_animation(run_animation)
		else:
			_play_animation(idle_animation)


func _play_animation(animation_name: StringName) -> void:
	if animation_player.current_animation == animation_name and animation_player.is_playing():
		return
	if not animation_player.has_animation(animation_name):
		return

	animation_player.play(animation_name, animation_blend_time)


func _is_animation_playing(animation_name: StringName) -> bool:
	return animation_player.current_animation == animation_name and animation_player.is_playing()


func _respawn_at_start() -> void:
	global_position = start_position
	velocity = Vector3.ZERO
	_play_animation(idle_animation)

func _on_sunrise():
	$Mage/Lantern.visible = false

func _on_sunset():
	$Mage/Lantern.visible = true
