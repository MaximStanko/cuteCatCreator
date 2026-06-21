extends CanvasLayer

const SLOT_COUNT := 4

const TOOLS := {
	"full_edge": {"symbol": "(C)", "items": ["Koi", "Trout", "Catfish", "Salmon", "Anchovy", "Pike", "Eel", "Tuna"]},
	"half_edge": {"symbol": "(L)", "items": ["Diamond"]},
	"cross":     {"symbol": "(X)", "items": ["Pink"]},
	"single":    {"symbol": "(I)", "items": ["CHEESE"]},
}

var slots: Array[Dictionary] = []
var current_slot: int = 0

var found: Dictionary = {
	"triangle": {"found": false, "cat": "res://assets/gartz/astronaut.tscn", "cat_name": "Astro Gadse"},
	"rhombus": {"found": false, "cat": "res://assets/gartz/broet.tscn", "cat_name": "Bröt Gadse"},
	"trapezoid": {"found": false, "cat": "res://assets/gartz/buff.tscn", "cat_name": "Buff Gadse"},
	"hexagon": {"found": false, "cat": "res://assets/gartz/chonk.tscn", "cat_name": "Chonker"},
	"pacman": {"found": false, "cat": "res://assets/gartz/Gatzenhai.tscn", "cat_name": "Gadsenhai"},
	"crooked_hourglass": {"found": false, "cat": "res://assets/gartz/gentlecat.tscn", "cat_name": "Gentlecat"},
	"hourglass": {"found": false, "cat": "res://assets/gartz/heckse.tscn", "cat_name": "Gadsmagie"},
	"crescent_moon": {"found": false, "cat": "res://assets/gartz/orange.tscn", "cat_name": "Orange Gadse"},
	"raft": {"found": false, "cat": "res://assets/gartz/poempl.tscn", "cat_name": "Pömpel Gatse"},
	"boat": {"found": false, "cat": "res://assets/gartz/rainbow.tscn", "cat_name": "Regenbogen Gadse"},
	"infinity": {"found": false, "cat": "res://assets/gartz/silly.tscn", "cat_name": "Silly Gadse"},
	"radioactive": {"found": false, "cat": "res://assets/gartz/unicorn.tscn", "cat_name": "Einhorn Gadse"},
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
	found[shape_name].found = true
		
func is_found(shape_name: String) -> bool:
	return found[shape_name].found

func found_count() -> int:
	var count := 0
	for shape_name in found:
		if found[shape_name].found:
			count += 1
	return count
	
func shape_to_cat(shape_name: String) -> String:
	return found[shape_name].cat
	
func shape_to_cat_name(shape_name: String) -> String:
	return found[shape_name].cat_name
	
func print_found_dictionary() -> void:
	var count := 1
	for shape_name in found:
		print(count, ": ", shape_name, " ", found[shape_name].found)
		count += 1

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
