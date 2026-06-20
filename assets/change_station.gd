class_name ChangeStation
extends Interactable

@export var delta: int = 5

@onready var _label: Label = $Body/Label

func _ready() -> void:
	super()
	_label.text = "+%d" % delta if delta >= 0 else str(delta)

func interact(inventory) -> void:
	inventory.modify_held_value(delta)
