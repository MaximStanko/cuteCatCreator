extends Node3D

@export var hexagonParentNode: Node3D

@onready var hexagonVertices: List[Node3D]

func _ready() -> void:
	for vertex in hexagonParentNode.get_children():
		

func _process(delta: float) -> void:
	pass
