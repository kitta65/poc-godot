extends Marker2D

@export var radius := 5.0
@export var deactivated_color := Color.WHITE
@export var activated_color := Color.ORANGE
var id: int = 0
var active: bool = false
@onready var clickable_shape: CollisionShape2D = $ClickableArea/ClickableShape

func _ready() -> void:
	if clickable_shape.shape is CircleShape2D:
		clickable_shape.shape.radius = radius
	else:
		printerr("Expected CircleShape2D, got: %s" % clickable_shape.shape)

	if id == 0:
		id = Utils.generate_id(self)


func _process(_delta: float) -> void:
	pass

func _draw() -> void:
	var color := activated_color if active else deactivated_color
	draw_circle(Vector2.ZERO, radius, color)

func init(scene: Node2D, position_: Vector2, operated: Signal) -> void:
	position = position_
	operated.connect(_on_main_operated)
	scene.add_child(self)

func load(scene: Node2D, data: Dictionary, operated) -> void:
	id = data["id"]
	position = Vector2(data["position.x"], data["position.y"])

	init(scene, position, operated)

func save() -> Dictionary:
	return {
		"type": Constants.ElementType.VERTEX,
		"id": id,
		"position.x": position.x,
		"position.y": position.y
	}

func _set_active(active_: bool) -> void:
	active = active_
	queue_redraw()

func interact() -> Types.Operation:
	_set_active(true)
	return Types.Operation.new(
		Types.OperationType.UNSPECIFIED,
		Constants.ElementType.VERTEX,
		id
	)

func delete() -> Types.Operation:
	var edges := get_tree().get_nodes_in_group("edge")
	for edge in edges:
		if (
			edge.start_vertex.get_ref() != self
			and edge.end_vertex.get_ref() != self
		):
			continue

		edge.delete()

	queue_free()
	return Types.Operation.new(
		Types.OperationType.DELETE,
		Constants.ElementType.VERTEX,
		id
	)


func _on_main_operated(operation: Types.Operation) -> void:
	if operation.element_id == id:
		pass
	else:
		_set_active(false)