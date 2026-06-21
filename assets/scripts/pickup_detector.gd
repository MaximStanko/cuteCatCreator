extends Area3D

@export var pickupName: String

var player_inside = false
@onready var _label: Label3D = $Label3D

func _ready() -> void:
	$Sprite3D.hide()

func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		player_inside = true
		$Sprite3D.show()
		

func _on_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		player_inside = false
		$Sprite3D.hide()
		
func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo() or !player_inside:
		return
	match (event as InputEventKey).physical_keycode:
		KEY_E: Inventory.give_item(pickupName)
