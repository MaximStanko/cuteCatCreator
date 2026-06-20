extends Node3D

var magicEdgePrefab: PackedScene = preload("res://assets/prefabs/magic_edge.tscn")

@export var hexagonParentNode: Node3D
@onready var hexagonVertices: Dictionary[int, Node]

var magicEdges: Dictionary = {
	[0, 1]: null, [1, 0]: null,
	[0, 2]: null, [2, 0]: null,
	[0, 3]: null, [3, 0]: null,
	[0, 4]: null, [4, 0]: null,
	[0, 5]: null, [5, 0]: null,
	[0, 6]: null, [6, 0]: null,
	[1, 2]: null, [2, 1]: null,
	[2, 3]: null, [3, 2]: null,
	[3, 4]: null, [4, 3]: null,
	[4, 5]: null, [5, 4]: null,
	[5, 6]: null, [6, 5]: null,
	[6, 1]: null, [1, 6]: null,
}

func spawnMagicEdge(from: int, to: int):
	if magicEdges.get([from, to]) == null:
		var magicEdge: Node = magicEdgePrefab.instantiate()
		add_child(magicEdge)
		magicEdges.set([from, to], magicEdge)
		
		var from_pos: Vector3 = hexagonVertices[from].position
		var to_pos: Vector3 = hexagonVertices[to].position
		magicEdge.position = (from_pos + to_pos) / 2.0
		var angle: float = atan2(to_pos.z - from_pos.z, to_pos.x - from_pos.x)
		magicEdge.rotation.y = -angle

func removeMagicEdge(from: int, to: int):
	var magicEdge = magicEdges.get([from, to])
	if magicEdge != null:
		magicEdge.queue_free()
		magicEdges.set([from, to], null)

func vertex_pressed(index: int):
	print("Vertex " + str(index) + " pressed")

func vertex_hovered(index: int):
	print("Vertex " + str(index) + " hovered")
	spawnMagicEdge(1, 2)

func vertex_unhovered(index: int):
	print("Vertex " + str(index) + " unhovered")
	removeMagicEdge(1, 2)

func _ready() -> void:
	hexagonVertices = {}
	for vertex in hexagonParentNode.get_children():
		var index: int = vertex.vertex_index
		hexagonVertices[index] = vertex
		vertex.connect("vertex_pressed", vertex_pressed.bind(index))
		vertex.connect("vertex_hovered", vertex_hovered.bind(index))
		vertex.connect("vertex_unhovered", vertex_unhovered.bind(index))
