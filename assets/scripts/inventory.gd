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
		KEY_Q: _discard()

func _select_slot(index: int) -> void:
	current_slot = index
	_refresh()

func set_held_item(item_name: String) -> void:
	slots[current_slot] = {"name": item_name}
	_select_slot((current_slot+1) % 4)
	_refresh()

func _discard() -> void:
	slots[current_slot] = {}
	_refresh()

func _refresh() -> void:
	for i in SLOT_COUNT:
		var item := slots[i]
		var content := "(empty)"
		if not item.is_empty():
			content = "%s" % [item.name]
		var marker := ">" if i == current_slot else " "
		_rows[i].text = "%s %d: %s" % [marker, i + 1, content]
		_rows[i].modulate = Color(1, 1, 0.5) if i == current_slot else Color(1, 1, 1)
