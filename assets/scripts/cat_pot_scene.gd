extends Node3D

var magicEdgePrefab: PackedScene = preload("res://assets/prefabs/magic_edge.tscn")

@export var hexagonParentNode: Node3D
@onready var hexagonVertices: Dictionary[int, Node]

var currentItem: String = "cross"
var currentOrientation: int = 0
var currentTempOrientation: int = 0
var currentMaxOrientation: int = 0
var currentEdgePossibilities = null

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

var itemColors: Dictionary = {
	"full_edge": Color(0.79, 0.83, 0.58),
	"half_edge": Color(0.627, 0.833, 0.661, 1.0),
	"cross": Color(0.83, 0.58, 0.79),
	"single": Color(0.617, 0.852, 0.854, 1.0),
}

var itemEdges: Dictionary = {
	"full_edge": {
		0: [
			[3, 5], [4, 6], [5, 1], [6, 2], [1, 3], [2, 4]
		],
		1: [
			[2, 6], null, null, null, null, null
		],
		2: [
			null, [3, 1], null, null, null, null
		],
		3: [
			null, null, [2, 4], null, null, null
		],
		4: [
			null, null, null, [3, 5], null, null
		],
		5: [
			null, null, null, null, [4, 6], null
		],
		6: [
			null, null, null, null, null, [5, 1]
		]
	},
	"half_edge": {
		0: [
			[3, 4], [4, 5], [5, 6], [6, 1], [1, 2], [2, 3]
		],
		1: [
			[2, 0], [0, 6], null, null, null, null
		],
		2: [
			null, [3, 0], [0, 1], null, null, null
		],
		3: [
			null, null, [4, 0], [0, 2], null, null
		],
		4: [
			null, null, null, [5, 0], [0, 3], null
		],
		5: [
			null, null, null, null, [6, 0], [0, 4]
		],
		6: [
			[0, 1], null, null, null, null, [5, 0]
		]
	},
	"cross": {
		0: [
			[2, 3, 5, 6],
			[1, 3, 4, 6],
			[1, 2, 4, 5],
		]
	},
	"single": {
		0: [
			[4], [5], [6], [1], [2], [3]
		],
		1: [
			[0], [6], null,null, null, [2]
		],
		2: [
			[3], [0], [1], null, null, null
		],
		3: [
			null, [4], [0], [2], null, null
		],
		4: [
			null, null, [5], [0], [3], null
		],
		5: [
			null, null, null, [6], [0], [4]
		],
		6: [
			[5], null, null, null, [1], [0]
		]
	},
}

func spawnMagicEdge(from: int, to: int, color: Color):
	if magicEdges.get([from, to]) == null:
		var magicEdge: Node = magicEdgePrefab.instantiate()
		magicEdges.set([from, to], magicEdge)
		
		var from_pos: Vector3 = hexagonVertices[from].position
		var to_pos: Vector3 = hexagonVertices[to].position
		magicEdge.position = (from_pos + to_pos) / 2.0
		magicEdge.rotation.y = - atan2(to_pos.z - from_pos.z, to_pos.x - from_pos.x)
		magicEdge.set_light_color(color)
		
		add_child(magicEdge)

func removeMagicEdge(from: int, to: int):
	var magicEdge = magicEdges.get([from, to])
	if magicEdge != null:
		magicEdge.queue_free()
		magicEdges.set([from, to], null)

func vertex_pressed(index: int):
	print("Vertex " + str(index) + " pressed")

func vertex_hovered(index: int):
	print("Vertex " + str(index) + " hovered")
	currentEdgePossibilities = itemEdges[currentItem].get(index)
	currentTempOrientation = currentOrientation
	if currentEdgePossibilities != null:
		currentMaxOrientation = currentEdgePossibilities.size()
		while currentEdgePossibilities[currentTempOrientation] == null:
			currentTempOrientation = (currentTempOrientation + 1) % currentMaxOrientation
		var currentEdges: Array = currentEdgePossibilities[currentTempOrientation]
		for vertex_to in currentEdges:
			spawnMagicEdge(index, vertex_to, itemColors[currentItem])
	else:
		currentMaxOrientation = 0

func vertex_unhovered(index: int):
	print("Vertex " + str(index) + " unhovered")
	currentMaxOrientation = 0
	for edge in magicEdges:
		if magicEdges[edge] != null:
			removeMagicEdge(edge[0], edge[1])

func item_rotated(index: int):
	print("rotated")
	if currentMaxOrientation > 0:
		currentTempOrientation = (currentTempOrientation + 1) % currentMaxOrientation
		while currentEdgePossibilities[currentTempOrientation] == null:
			currentTempOrientation = (currentTempOrientation + 1) % currentMaxOrientation
		currentOrientation = currentTempOrientation
		vertex_unhovered(index)
		vertex_hovered(index)

func _ready() -> void:
	hexagonVertices = {}
	for vertex in hexagonParentNode.get_children():
		var index: int = vertex.vertex_index
		hexagonVertices[index] = vertex
		vertex.connect("vertex_pressed", vertex_pressed.bind(index))
		vertex.connect("item_rotated", item_rotated.bind(index))
		vertex.connect("vertex_hovered", vertex_hovered.bind(index))
		vertex.connect("vertex_unhovered", vertex_unhovered.bind(index))
