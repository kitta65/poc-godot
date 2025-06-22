extends Line2D

@export var deactivated_color := Color.WHITE
@export var activated_color := Color.ORANGE
@export var line_width := 3.0
var id: int = 0
var start_vertex: WeakRef
var end_vertex: WeakRef
@onready var clickable_polygon: CollisionPolygon2D = $ClickableArea/ClickablePolygon

func _ready() -> void:
	default_color = deactivated_color
	width = line_width
	var start_position: Vector2 = start_vertex.get_ref().position
	var end_position: Vector2 = end_vertex.get_ref().position
	add_point(start_position)
	add_point(end_position)
	id = Utils.generate_id(self)

	var polygon := PackedVector2Array()
	var normal_vector := (end_position - start_position).rotated(PI / 2).normalized()
	polygon.append(start_position - normal_vector * line_width / 2)
	polygon.append(start_position + normal_vector * line_width / 2)
	polygon.append(end_position + normal_vector * line_width / 2)
	polygon.append(end_position - normal_vector * line_width / 2)
	clickable_polygon.polygon = polygon

func _process(_delta: float) -> void:
	pass


func init(scene: Node2D, vertices: Array[Node], operated: Signal) -> void:
	if vertices.size() != 2:
		printerr("The size of vertices should be 2, got: %d" % vertices.size())
		return

	start_vertex = weakref(vertices[0])
	end_vertex = weakref(vertices[1])

	operated.connect(_on_main_operated)
	scene.add_child(self)


func delete() -> Types.Operation:
	queue_free()
	return Types.Operation.new(
		Types.OperationType.DELETE,
		Constants.ElementType.EDGE,
		id
	)


func _on_main_operated(_operation: Types.Operation) -> void:
	pass
