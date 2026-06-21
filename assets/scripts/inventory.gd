extends CanvasLayer

signal rotate_item(item)
signal place_item(item)
signal change_selected_item

const SLOT_COUNT := 4

const TOOLS := {
	"full_edge": {"symbol": "(C)", "items": ["Koi", "Trout", "Catfish", "Salmon", "Anchovy", "Pike", "Eel", "Tuna"]},
	"half_edge": {"symbol": "(L)", "items": ["Diamond"]},
	"cross":     {"symbol": "(X)", "items": ["Miaunkohle"]},
	"single":    {"symbol": "(I)", "items": ["Pilz"]},
}

var slots: Array[Dictionary] = []
var current_slot: int = 0

var found: Dictionary = {
	"triangle": false,
	"rhombus": false,
	"trapezoid": false,
	"hexagon": false,
	"pacman": false,
	"crooked_hourglass": false,
	"hourglass": false,
	"crescent_moon": false,
	"raft": false,
	"boat": false,
	"infinity": false,
	"radioactive": false,
}

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

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	
	if event.is_action_pressed("rotate_item"):
		rotate_item.emit(peek_held_tool())
	if event.is_action_pressed("place_item"):
		place_item.emit(peek_held_tool())
	
	for i in range(4):
		if event.is_action_pressed("slot" + str(i + 1)):
			_select_slot(i)
	if event.is_action_pressed("discard_item"):
		_discard()

func _select_slot(index: int) -> void:
	current_slot = index
	_refresh()

func _discard() -> void:
	slots[current_slot] = {}
	_refresh()

func tool_for_item(item_name: String) -> String:
	for tool in TOOLS:
		if item_name in TOOLS[tool].items:
			return tool
	return ""

func peek_held_tool() -> String:
	var item := slots[current_slot]
	if item.is_empty():
		return ""
	return tool_for_item(item.name)

func take_held_item() -> String:
	var item := slots[current_slot]
	if item.is_empty() or tool_for_item(item.name) == "":
		return ""
	slots[current_slot] = {}
	_refresh()
	return item.name

func give_item(item_name: String) -> void:
	for i in SLOT_COUNT:
		if slots[i].is_empty():
			slots[i] = {"name": item_name}
			_refresh()
			return
	slots[current_slot] = {"name": item_name}
	_refresh()

func mark_found(shape_name: String) -> void:
	if found.has(shape_name):
		found[shape_name] = true

func found_count() -> int:
	var count := 0
	for shape_name in found:
		if found[shape_name]:
			count += 1
	return count

func _refresh() -> void:
	for i in SLOT_COUNT:
		var item := slots[i]
		var content := "(empty)"
		if not item.is_empty():
			var tool := tool_for_item(item.name)
			var prefix: String = TOOLS[tool].symbol if tool != "" else ""
			content = ("%s %s" % [prefix, item.name]).strip_edges()
		var marker := ">" if i == current_slot else " "
		_rows[i].text = "%s %d: %s" % [marker, i + 1, content]
		_rows[i].modulate = Color(1, 1, 0.5) if i == current_slot else Color(1, 1, 1)
	change_selected_item.emit()
