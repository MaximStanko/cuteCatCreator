extends Node3D

func _ready() -> void:
	GameManager.update_compendium.connect(update)

func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		self.visible = false

func update():
	if Inventory.is_found("triangle"):
		$spinnings/leftpage/astronaut.show()
		$spinnings/leftpage/un1.hide()
		$spinnings/leftpage/cat1.text = "Astronaut"
	if Inventory.is_found("rhombus"):
		$spinnings/leftpage/brot.show()
		$spinnings/leftpage/un2.hide()
		$spinnings/leftpage/cat2.text = "Brot"
	if Inventory.is_found("trapezoid"):
		$spinnings/leftpage/buff.show()
		$spinnings/leftpage/un3.hide()
		$spinnings/leftpage/cat3.text = "Buff"
	if Inventory.is_found("hexagon"):
		$spinnings/leftpage/chonk.show()
		$spinnings/leftpage/un4.hide()
		$spinnings/leftpage/cat4.text = "Chonk"
	if Inventory.is_found("pacman"):
		$spinnings/leftpage/hai.show()
		$spinnings/leftpage/un5.hide()
		$spinnings/leftpage/cat5.text = "Gatzenhai"
	if Inventory.is_found("crooked_hourglass"):
		$spinnings/leftpage/gentlecat.show()
		$spinnings/leftpage/un6.hide()
		$spinnings/leftpage/cat6.text = "Gentlecat"
	if Inventory.is_found("hourglass"):
		$spinnings/rightpage/hexe.show()
		$spinnings/rightpage/un1.hide()
		$spinnings/rightpage/cat1.text = "Hexe"
	if Inventory.is_found("crescent_moon"):
		$spinnings/rightpage/orange.show()
		$spinnings/rightpage/un2.hide()
		$spinnings/rightpage/cat2.text = "Orange"
	if Inventory.is_found("raft"):
		$spinnings/rightpage/poempl.show()
		$spinnings/rightpage/un3.hide()
		$spinnings/rightpage/cat3.text = "Pömpl"
	if Inventory.is_found("boat"):
		$spinnings/rightpage/rainbow.show()
		$spinnings/rightpage/un4.hide()
		$spinnings/rightpage/cat4.text = "Rainbow"
	if Inventory.is_found("infinity"):
		$spinnings/rightpage/silly.show()
		$spinnings/rightpage/un5.hide()
		$spinnings/rightpage/cat5.text = "Silly"
	if Inventory.is_found("radioactive"):
		$spinnings/rightpage/unicorn.show()
		$spinnings/rightpage/un6.hide()
		$spinnings/rightpage/cat6.text = "Unicorn"
