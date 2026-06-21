extends Node

@onready var _label = $CanvasLayer/Control/Label
@onready var journal_backdrop = $journal_backdrop

func _on_static_body_3d_input_event(camera, event, event_position, normal, shape_idx):
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		print("%d/12" % Inventory.found_count())
		_label.text = ""
		for shape in Inventory.found.keys():
			_label.text += "- "
			if Inventory.is_found(shape):
				_label.text += Inventory.shape_to_cat_name(shape)
			else:
				_label.text += "???"
			_label.text += " (" + shape + ", " + str(Inventory.is_found(shape)) + ")\n"
		_label.text += "Overall: " + str(Inventory.found_count()) + "/12"
		$"../Camera3D/CompendiumOverlay".visible = true
