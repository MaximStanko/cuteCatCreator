extends Node


func _ready() -> void:
	self.visible = false


func _on_pickup_detector_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		self.visible = true


func _on_pickup_detector_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		self.visible = false
