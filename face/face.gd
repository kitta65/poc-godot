extends Element

@export var deactivated_color := Color.WHITE
@export var activated_color := Color.ORANGE
var edge0: WeakRef
var edge1: WeakRef
var edge2: WeakRef

@onready var clickable_polygon: CollisionPolygon2D = $ClickableArea/ClickablePolygon
@onready var appearance_polygon: Polygon2D = $AppearancePolygon

#region virtual functions
func _ready() -> void:
	appearance_polygon.color = deactivated_color
	var polygon := PackedVector2Array()
	var vertexIds = []
	for edge in [edge0, edge1, edge2]:
		var start_vertex = edge.get_ref().start_vertex.get_ref()
		var end_vertex = edge.get_ref().end_vertex.get_ref()
		for vertex in [start_vertex, end_vertex]:
			if vertex.id in vertexIds:
				continue
			vertexIds.append(vertex.id)
			polygon.append(vertex.position)
	appearance_polygon.polygon = polygon
	clickable_polygon.polygon = polygon

	if id == 0:
		id = Utils.generate_id(self)
#endregion

#region signals handlers
func _on_main_operated(_operation: Types.Operation) -> void:
	pass
#endregion

func init(scene: Node2D, edges: Array[Node], operated: Signal) -> void:
	if edges.size() != 3:
		printerr("The size of edges should be 3, got: %d" % edges.size())
		return

	edge0 = weakref(edges[0])
	edge1 = weakref(edges[1])
	edge2 = weakref(edges[2])

	_instantiate(scene, operated)

func load(scene: Node2D, data: Dictionary, operated) -> void:
	id = data["id"]
	var edges := scene.get_tree().get_nodes_in_group("edge")
	var filtered_edges := edges.filter(func(e): return (
		e.id == data["edge0"]
		or e.id == data["edge1"]
		or e.id == data["edge2"]
	))
	init(scene, filtered_edges, operated)

func save(file: FileAccess) -> void:
	var data := {
		"type": type(),
		"id": id,
		"edge0": edge0.get_ref().id,
		"edge1": edge1.get_ref().id,
		"edge2": edge2.get_ref().id,
	}
	return file.store_line(JSON.stringify(data))

func type() -> Constants.ElementType:
	return Constants.ElementType.FACE