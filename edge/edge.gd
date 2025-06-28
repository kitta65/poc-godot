extends Element

@export var deactivated_color := Color.WHITE
@export var activated_color := Color.ORANGE
@export var width := 3.0
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

	if id == 0:
		id = Utils.generate_id(self)

	var polygon := PackedVector2Array()
	var normal_vector := (end_position - start_position).rotated(PI / 2).normalized()
	polygon.append(start_position - normal_vector * width / 2)
	polygon.append(start_position + normal_vector * width / 2)
	polygon.append(end_position + normal_vector * width / 2)
	polygon.append(end_position - normal_vector * width / 2)
	clickable_polygon.polygon = polygon

func _process(_delta: float) -> void:
	pass
#endregion


#region signals handlers
func _on_main_operated(_operation: Types.Operation) -> void:
	pass
#endregion


func init(scene: Node2D, vertices: Array[Node], operated: Signal) -> void:
	if vertices.size() != 2:
		printerr("The size of vertices should be 2, got: %d" % vertices.size())
		return

	start_vertex = weakref(vertices[0])
	end_vertex = weakref(vertices[1])

	_instantiate(scene, operated)

func load(scene: Node2D, data: Dictionary, operated) -> void:
	id = data["id"]
	var vertices := scene.get_tree().get_nodes_in_group("vertex")
	var filtered_vertices := vertices.filter(func(v): return v.id == data["start"] or v.id == data["end"])
	init(scene, filtered_vertices, operated)

func save(file: FileAccess) -> void:
	var data := {
		"type": Constants.ElementType.EDGE,
		"id": id,
		"start": start_vertex.get_ref().id,
		"end": end_vertex.get_ref().id,
	}
	return file.store_line(JSON.stringify(data))

func type() -> Constants.ElementType:
	return Constants.ElementType.EDGE
