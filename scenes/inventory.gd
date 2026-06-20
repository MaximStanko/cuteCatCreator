extends CanvasLayer

const SLOT_COUNT := 4

var slots: Array[Dictionary] = []
var current_slot: int = 0

var _rows: Array[Label] = []

@onready var _vbox: VBoxContainer = $Panel/VBox

func _ready() -> void:
	slots.resize(SLOT_COUNT)
	for i in SLOT_COUNT:
		slots[i] = {}
	var title := Label.new()
	title.text = "Inventory"
	_vbox.add_child(title)
	for i in SLOT_COUNT:
		var row := Label.new()
		_vbox.add_child(row)
		_rows.append(row)
	_refresh()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	match (event as InputEventKey).physical_keycode:
		KEY_1: _select_slot(0)
		KEY_2: _select_slot(1)
		KEY_3: _select_slot(2)
		KEY_4: _select_slot(3)
		KEY_E: _interact()
		KEY_Q: _discard()

func _select_slot(index: int) -> void:
	current_slot = index
	_refresh()

func _interact() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var nearest: Interactable = null
	var nearest_dist := INF
	for node in get_tree().get_nodes_in_group("interactables"):
		var target := node as Interactable
		if not target.player_in_range:
			continue
		var dist := 0.0 if player == null else player.global_position.distance_to(target.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = target
	if nearest != null:
		nearest.interact(self)

func set_held_item(item_name: String, value: int) -> void:
	slots[current_slot] = {"name": item_name, "value": value, "modified": false}
	_refresh()

func modify_held_value(delta: int) -> void:
	var item := slots[current_slot]
	if item.is_empty() or item.modified:
		return
	item.value = clampi(item.value + delta, 1, 179)
	item.modified = true
	_refresh()

func _discard() -> void:
	slots[current_slot] = {}
	_refresh()

func _refresh() -> void:
	for i in SLOT_COUNT:
		var item := slots[i]
		var content := "(empty)"
		if not item.is_empty():
			var star := " *" if item.modified else ""
			content = "%s [%d]%s" % [item.name, item.value, star]
		var marker := ">" if i == current_slot else " "
		_rows[i].text = "%s %d: %s" % [marker, i + 1, content]
		_rows[i].modulate = Color(1, 1, 0.5) if i == current_slot else Color(1, 1, 1)
