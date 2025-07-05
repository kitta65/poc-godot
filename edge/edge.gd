extends Element

@export var deactivated_color := Color.WHITE
@export var activated_color := Color.ORANGE
@export var width := 10.0
var active := false
var start_vertex: WeakRef
var end_vertex: WeakRef
@onready var clickable_polygon: CollisionPolygon2D = $ClickableArea/ClickablePolygon
@onready var line2d: Line2D = $Line2D

#region virtual functions
func _ready() -> void:
	line2d.default_color = deactivated_color
	line2d.width = width
	var start_position: Vector2 = start_vertex.get_ref().position
	var end_position: Vector2 = end_vertex.get_ref().position
	line2d.add_point(start_position)
	line2d.add_point(end_position)

	var polygon := PackedVector2Array()
	var normal_vector := (end_position - start_position).rotated(PI / 2).normalized()
	polygon.append(start_position - normal_vector * width / 2)
	polygon.append(start_position + normal_vector * width / 2)
	polygon.append(end_position + normal_vector * width / 2)
	polygon.append(end_position - normal_vector * width / 2)
	clickable_polygon.polygon = polygon

	super._ready()

func _process(_delta: float) -> void:
	pass
#endregion


#region signals handlers
func _on_main_operated(operation: Types.Operation) -> void:
	if operation.element_id == id:
		return # NOP

	if operation.element_type != type():
		_set_active(false)
		return

	# TODO: refactor
	var edges := get_tree().get_nodes_in_group("edge")
	var idx := edges.map(func(e): return e.id).find(operation.element_id)
	if idx == -1:
		_set_active(false)
		return

	var edge := edges[0]
	var has_shared_vertex := false
	if start_vertex.get_ref().id in [edge.start_vertex.get_ref().id, edge.end_vertex.get_ref().id]:
		has_shared_vertex = true
	elif end_vertex.get_ref().id in [edge.start_vertex.get_ref().id, edge.end_vertex.get_ref().id]:
		has_shared_vertex = true

	if not has_shared_vertex:
		_set_active(false)
		return
#endregion


func delete() -> Types.Operation:
	var faces := get_tree().get_nodes_in_group("face")
	for face in faces:
		if (
			face.edge0.get_ref() != self
			and face.edge1.get_ref() != self
			and face.edge2.get_ref() != self
		):
			continue

		face.delete()

	return super.delete()

func init(scene: Node2D, vertices: Array[Node], operated: Signal) -> void:
	if vertices.size() != 2:
		printerr("The size of vertices should be 2, got: %d" % vertices.size())
		return

	start_vertex = weakref(vertices[0])
	end_vertex = weakref(vertices[1])

	_instantiate(scene, operated)

func interact() -> Types.Operation:
	var operation := Types.Operation.new(
		 Types.OperationType.DEACTIVATE if active else Types.OperationType.ACTIVATE,
		type(),
		id
	)
	_set_active(not active)
	return operation

func load(scene: Node2D, data: Dictionary, operated) -> void:
	id = data["id"]
	var vertices := scene.get_tree().get_nodes_in_group("vertex")
	var filtered_vertices := vertices.filter(func(v): return v.id == data["start"] or v.id == data["end"])
	init(scene, filtered_vertices, operated)

func save(file: FileAccess) -> void:
	var data := {
		"type": type(),
		"id": id,
		"start": start_vertex.get_ref().id,
		"end": end_vertex.get_ref().id,
	}
	return file.store_line(JSON.stringify(data))

func _set_active(active_: bool) -> void:
	active = active_
	line2d.default_color = activated_color if active else deactivated_color
	# queue_redraw() may be needed

func type() -> Constants.ElementType:
	return Constants.ElementType.EDGE
