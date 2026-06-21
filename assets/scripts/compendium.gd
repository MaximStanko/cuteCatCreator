extends Node

func _on_static_body_3d_input_event(camera, event, event_position, normal, shape_idx):
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		print("compendium clicked!")
		$CanvasLayer/Control.visible = true
