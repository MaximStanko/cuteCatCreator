class_name PickupPoint
extends Interactable

@export var item_name: String = "Item"
@export var item_color: Color = Color.WHITE
@export var item_symbol: String = "?"
@export_range(1, 179) var item_value: int = 1

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _symbol: Label = $Bubble/Symbol

func _ready() -> void:
	super()
	_sprite.modulate = item_color
	_symbol.text = item_symbol

func interact(inventory) -> void:
	inventory.set_held_item(item_name, item_value)
