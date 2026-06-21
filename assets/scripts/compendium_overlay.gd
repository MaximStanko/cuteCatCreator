extends Node

func _on_button_button_down():
	self.visible = false
	$"../../spinnings".hide()
	$"../../journal_backdrop".hide()
