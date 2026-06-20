extends Node

var detector

func _ready() -> void:
	self.text = "?"
	detector = get_parent()


func _on_pickup_detector_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		self.text = "!"


func _on_pickup_detector_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		self.text = detector.pickupName
