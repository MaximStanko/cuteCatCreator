extends Area3D

const MINIGAME := preload("res://assets/prefabs/fishing_minigame.tscn")

var player_inside: bool = false
var _game: Node = null

@onready var _label: Label3D = $Label3D

func _ready() -> void:
	_label.text = "🐟"

func _on_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.is_in_group("player"):
		player_inside = true
		_label.text = "!"

func _on_body_shape_exited(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.is_in_group("player"):
		player_inside = false
		_label.text = "🐟"

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo() or not player_inside or _game:
		return
	if (event as InputEventKey).physical_keycode == KEY_E:
		_game = MINIGAME.instantiate()
		_game.finished.connect(_on_finished)
		get_tree().root.add_child(_game)
		_game.start()

func _on_finished(success: bool, item_name: String) -> void:
	_game = null
	if success:
		Inventory.set_held_item(item_name)
