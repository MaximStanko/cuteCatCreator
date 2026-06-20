class_name TransitionPoint
extends Interactable

@export_file("*.tscn") var target_scene: String = ""
@export var label_text: String = "Enter"

@onready var _label: Label = $Label

func _ready() -> void:
	super()
	_label.text = label_text

func interact(_inventory) -> void:
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
