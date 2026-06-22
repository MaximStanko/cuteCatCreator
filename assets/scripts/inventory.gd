extends CanvasLayer

signal rotate_item(item)
signal place_item(item)
signal change_selected_item

const SLOT_COUNT := 4

const TOOLS := {
	"full_edge": {"symbol": "(L)", "texture": preload("res://assets/image_previews/fish.png"), "items": ["Koi", "Trout", "Catfish", "Salmon", "Anchovy", "Pike", "Eel", "Tuna"]},
	"half_edge": {"symbol": "(<)", "texture": preload("res://assets/image_previews/gem.png"), "items": ["Diamond"]},
	"cross":     {"symbol": "(X)", "texture": preload("res://assets/image_previews/sugar.png"), "items": ["Pink"]},
	"single":    {"symbol": "(I)", "texture": preload("res://assets/image_previews/cheese.png"), "items": ["CHEESE"]},
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
@onready var slotNodes: Array[TextureRect] = [$slot1, $slot2, $slot3, $slot4]
@onready var slotSurrounds: Array[Sprite2D] = [$Surround1, $Surround2, $Surround3, $Surround4]

var is_cat_up = false

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
	_select_slot(0)
	_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("slots_cycle_down"):
		current_slot = (current_slot + 1) % 4
		_select_slot(current_slot)
		_refresh()
	if event.is_action_pressed("slots_cycle_up"):
		current_slot -= 1
		if current_slot < 0:
			current_slot = 3
		_select_slot(current_slot)
		_refresh()
	
	if not event.is_pressed() or event.is_echo():
		return
	
	if event.is_action_pressed("rotate_item"):
		if is_cat_up:
			is_cat_up = false
			get_tree().reload_current_scene()
		rotate_item.emit(peek_held_tool())
	if event.is_action_pressed("place_item"):
		if is_cat_up:
			is_cat_up = false
			get_tree().reload_current_scene()
		place_item.emit(peek_held_tool())
	
	for i in range(4):
		if event.is_action_pressed("slot" + str(i + 1)):
			_select_slot(i)
	if event.is_action_pressed("discard_item"):
		_discard()

func _select_slot(index: int) -> void:
	for surround in slotSurrounds:
		surround.visible = false
	current_slot = index
	slotSurrounds[index].visible = true
	_refresh()

func _discard() -> void:
	slots[current_slot] = {}
	remove_item_preview(current_slot)
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
	remove_item_preview(current_slot)
	slots[current_slot] = {}
	var og_current_slot = current_slot
	while slots[current_slot].is_empty():
		current_slot = (current_slot + 1) % 4
		if current_slot == og_current_slot:
			break
	_select_slot(current_slot)
	_refresh()
	return item.name

func give_item(item_name: String) -> void:
	for i in SLOT_COUNT:
		if slots[i].is_empty():
			slots[i] = {"name": item_name}
			_select_slot(i)
			add_item_preview(item_name, i)
			_refresh()
			return
	slots[current_slot] = {"name": item_name}
	add_item_preview(item_name, current_slot)
	_refresh()

func add_item_preview(item_name: String, slot_id: int):
	slotNodes[slot_id].texture = TOOLS[tool_for_item(item_name)].texture

func remove_item_preview(slot_id: int):
	slotNodes[slot_id].texture = null

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
	change_selected_item.emit()

func _slot_input(event: InputEvent, index: int):
	if event.is_action_pressed("gui_select"):
		_select_slot(index)

func _on_slot_1_gui_input(event: InputEvent) -> void:
	_slot_input(event, 0)

func _on_slot_2_gui_input(event: InputEvent) -> void:
	_slot_input(event, 1)

func _on_slot_3_gui_input(event: InputEvent) -> void:
	_slot_input(event, 2)

func _on_slot_4_gui_input(event: InputEvent) -> void:
	_slot_input(event, 3)
