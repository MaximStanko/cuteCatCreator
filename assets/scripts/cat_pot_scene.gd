extends Node3D

var magicEdgePrefab: PackedScene = preload("res://assets/prefabs/magic_edge.tscn")
var magicEdgeIndicatorPrefab: PackedScene = preload("res://assets/prefabs/magic_edge_indicator.tscn")

var itemCheese = preload("res://assets/prefabs/item_cheese.tscn")
var itemGem = preload("res://assets/prefabs/item_gem.tscn")
var itemFish = preload("res://assets/prefabs/item_fish.tscn")
var itemSugar = preload("res://assets/prefabs/item_sugar.tscn")

@export var summonButton: TextureButton
@export var hexagonParentNode: Node3D
@onready var hexagonVertices: Dictionary[int, Node]
@onready var catAnimator = $CatContainer

var hexagonItemInstances = [null, null, null, null, null, null, null]

var currentItem: String = "full_edge"
var currentOrientation: int = 0
var currentTempOrientation: int = 0
var currentMaxOrientation: int = 0
var currentEdgePossibilities = null
var currentEdges = null
var selectedVertex = null

var verticesUsed: Array = [
	null, null, null, null, null, null, null
]

var itemsUsed: Array = [
	null, null, null, null, null, null, null
]

var shapes: Dictionary = {
	3: {
		"triangle": [[1, 2], [0, 1], [0, 2]], 
	},
	4: {
		"rhombus": [[1, 2], [0, 2], [0, 6], [1, 6]],
	},
	5: {
		"trapezoid": [[1, 2], [0, 2], [0, 5], [5, 6], [6, 1]],
	},
	6: {
		"hexagon": [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [1, 6]],
		"pacman": [[1, 2], [2, 3], [0, 3], [0, 5], [5, 6], [1, 6]],
		"crooked_hourglass": [[1, 2], [0, 1], [0, 2], [0, 5], [5, 6], [0, 6]],
		"hourglass": [[1, 2], [0, 1], [0, 2], [0, 5], [4, 5], [0, 4]],
	},
	7: {
		"crescent_moon": [[1, 2], [2, 3], [0, 3], [0, 4], [4, 5], [5, 6], [1, 6]],
		"raft": [[1, 2], [0, 1], [0, 2], [0, 6], [5, 6], [4, 5], [0, 4]],
	},
	8: {
		"boat": [[0, 1], [1, 2], [0, 2], [0, 6], [5, 6], [4, 5], [3, 4], [0, 3]],
		"infinity": [[1, 2], [2, 3], [0, 3], [0, 1], [0, 6], [5, 6], [4, 5], [0, 4]],
	},
	9: {
		"radioactive": [[1, 2], [0, 2], [0, 1], [0, 3], [0, 4], [3, 4], [0, 5], [0, 6], [5, 6]],
	}
}

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

var magicEdgesLocked: Dictionary = {
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
			[0, 5], null, null, null, null, [1, 0]
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
		var magicEdge: Node = magicEdgeIndicatorPrefab.instantiate()
		magicEdges.set([from, to], magicEdge)
		
		var from_pos: Vector3 = hexagonVertices[from].position
		var to_pos: Vector3 = hexagonVertices[to].position
		magicEdge.position = (from_pos + to_pos) / 2.0
		magicEdge.rotation.y = PI - atan2(to_pos.z - from_pos.z, to_pos.x - from_pos.x)
		magicEdge.set_light_color(color)
		
		add_child(magicEdge)

func spawnLockedMagicEdge(from: int, to: int, color: Color):
	if magicEdgesLocked.get([from, to]) == null:
		var magicEdge: Node = magicEdgePrefab.instantiate()
		magicEdgesLocked.set([from, to], magicEdge)
		
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

func removeLockedMagicEdge(from: int, to: int):
	var magicEdge = magicEdgesLocked.get([from, to])
	if magicEdge != null:
		magicEdge.queue_free()
		magicEdgesLocked.set([from, to], null)

func checkShape():
	var edges = []
	for edge in magicEdgesLocked:
		if magicEdgesLocked[edge] != null:
			edges.append([edge[0], edge[1]])
	
	var vertex_count = edges.size()
	if not shapes.has(vertex_count):
		return
	
	for i in range(vertex_count):
		if edges[i][0] > edges[i][1]:
			edges[i] = [edges[i][1], edges[i][0]]
	for rotationSummand in range(6):
		for shape_name in shapes[vertex_count]:
			edges.sort()
			print(edges, shapes[vertex_count][shape_name])
			if shapes[vertex_count][shape_name] == edges:
				return shape_name
		for i in range(vertex_count):
			if edges[i][0] != 0:
				edges[i][0] = (edges[i][0] % 6) + 1
			if edges[i][1] != 0:
				edges[i][1] = (edges[i][1] % 6) + 1
			if edges[i][0] > edges[i][1]:
				edges[i] = [edges[i][1], edges[i][0]]
	
	for i in range(vertex_count):
		if edges[i][0] == 2:
			edges[i][0] = 6
		if edges[i][1] == 2:
			edges[i][1] = 6
		if edges[i][0] == 3:
			edges[i][0] = 5
		if edges[i][1] == 3:
			edges[i][1] = 5
		if edges[i][0] > edges[i][1]:
			edges[i] = [edges[i][1], edges[i][0]]
	
	for rotationSummand in range(6):
		for shape_name in shapes[vertex_count]:
			edges.sort()
			print(edges, shapes[vertex_count][shape_name])
			if shapes[vertex_count][shape_name] == edges:
				return shape_name
		for i in range(vertex_count):
			if edges[i][0] != 0:
				edges[i][0] = (edges[i][0] % 6) + 1
			if edges[i][1] != 0:
				edges[i][1] = (edges[i][1] % 6) + 1
			if edges[i][0] > edges[i][1]:
				edges[i] = [edges[i][1], edges[i][0]]
	
	return null

func handleSummonButton():
	var shape_name = checkShape()
	summonButton.visible = (shape_name != null)

func remove_vertex(index: int):
	var edges = verticesUsed[index]
	if hexagonItemInstances[index] != null:
		hexagonItemInstances[index].queue_free()
	if edges != null:
		for edge in edges:
			removeLockedMagicEdge(edge[0], edge[1])
		verticesUsed[index] = null
		if itemsUsed[index] != null:
			Inventory.give_item(itemsUsed[index])
			itemsUsed[index] = null
		handleSummonButton()

func add_vertex(index: int, edges, tool):
	verticesUsed[index] = edges
	var item = tool
	if edges != null and item != "" and item != null:
		var instance = null
		match tool:
			"full_edge":
				instance = itemFish.instantiate()
			"half_edge":
				instance = itemGem.instantiate()
			"cross":
				instance = itemSugar.instantiate()
			"single":
				instance = itemCheese.instantiate()
		if instance != null:
			instance.global_position = hexagonVertices[index].global_position
			instance.scale = Vector3(0.1, 0.1, 0.1)
			add_child(instance)
			hexagonItemInstances[index] = instance
		for edge in edges:
			spawnLockedMagicEdge(edge[0], edge[1], itemColors.get(item))
		handleSummonButton()

func vertex_pressed(tool):
	var index = selectedVertex
	if index == null:
		return
	print("Vertex " + str(index) + " pressed")
	if verticesUsed[index] != null:
		remove_vertex(index)
		vertex_hovered(index)
	else:
		if currentEdges == null:
			return
		var full_edges = []
		for edge in currentEdges:
			full_edges.append([index, edge])
			if magicEdgesLocked.get([index, edge]) != null or magicEdgesLocked.get([edge, index]) != null:
				return
		var item := Inventory.take_held_item()
		if item == "":
			return
		itemsUsed[index] = item
		add_vertex(index, full_edges, tool)

func vertex_hovered(index: int):
	selectedVertex = index
	print("Vertex " + str(index) + " hovered")
	if verticesUsed[index] != null:
		return
	currentItem = Inventory.peek_held_tool()
	if currentItem == "":
		currentMaxOrientation = 0
		return
	currentEdgePossibilities = itemEdges[currentItem].get(index)
	currentTempOrientation = currentOrientation
	if currentEdgePossibilities != null:
		currentMaxOrientation = currentEdgePossibilities.size()
		while currentEdgePossibilities[currentTempOrientation] == null:
			currentTempOrientation = (currentTempOrientation + 1) % currentMaxOrientation
		currentEdges = currentEdgePossibilities[currentTempOrientation]
		for vertex_to in currentEdges:
			spawnMagicEdge(index, vertex_to, itemColors[currentItem])
	else:
		currentMaxOrientation = 0

func vertex_unhovered(index: int):
	selectedVertex = null
	print("Vertex " + str(index) + " unhovered")
	currentMaxOrientation = 0
	currentEdges = null
	for edge in magicEdges:
		if magicEdges[edge] != null:
			removeMagicEdge(edge[0], edge[1])

func item_rotated(item):
	var index = selectedVertex
	if index == null:
		return
	print("Vertex " + str(index) + " rotated")
	if currentMaxOrientation > 0:
		currentTempOrientation = (currentTempOrientation + 1) % currentMaxOrientation
		while currentEdgePossibilities[currentTempOrientation] == null:
			currentTempOrientation = (currentTempOrientation + 1) % currentMaxOrientation
		currentOrientation = currentTempOrientation
		_refresh()

func _refresh():
	var index = selectedVertex
	if index != null:
		vertex_unhovered(index)
		vertex_hovered(index)

func _ready() -> void:
	$Camera3D.position = Vector3(-0.187, 1.937, 0.907)
	$Camera3D.rotation_degrees.x = -65.3
	
	summonButton.visible = false
	
	Inventory.rotate_item.connect(item_rotated)
	Inventory.place_item.connect(vertex_pressed)
	Inventory.change_selected_item.connect(_refresh)
	
	for vertex_count in shapes:
		for shape_name in shapes[vertex_count]:
			shapes[vertex_count][shape_name].sort()
	
	hexagonVertices = {}
	for vertex in hexagonParentNode.get_children():
		var index: int = vertex.vertex_index
		hexagonVertices[index] = vertex
		vertex.connect("vertex_pressed", vertex_pressed.bind(index))
		vertex.connect("item_rotated", item_rotated.bind(index))
		vertex.connect("vertex_hovered", vertex_hovered.bind(index))
		vertex.connect("vertex_unhovered", vertex_unhovered.bind(index))

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		for item in itemsUsed:
			if item != null:
				Inventory.give_item(item)
		GameManager.player_rot = Vector3(0,38.8,0)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().change_scene_to_file("res://scenes/world888.tscn")

func _on_summon_button_button_up() -> void:
	var shape_name = checkShape()
	if shape_name != null:
		catAnimator.summon(shape_name)
		Inventory.mark_found(shape_name)
		print("I have summoned a cat")
		
		verticesUsed = [
			null, null, null, null, null, null, null
		]
		itemsUsed = [
			null, null, null, null, null, null, null
		]
