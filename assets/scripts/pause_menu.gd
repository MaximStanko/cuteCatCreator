extends Control

func _ready() -> void:
	hide()
	$resumeButton.pressed.connect(_on_play)
	$quitButton.pressed.connect(_on_quit)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	var paused := not get_tree().paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = paused
	visible = paused
	Inventory.visible = not paused

func _on_play() -> void:
	Inventory.show()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()
	
func _on_quit() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	Inventory.hide()
