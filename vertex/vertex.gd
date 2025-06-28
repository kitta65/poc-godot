extends Element

@export var radius := 5.0
@export var deactivated_color := Color.WHITE
@export var activated_color := Color.ORANGE
var active: bool = false
@onready var clickable_shape: CollisionShape2D = $ClickableArea/ClickableShape

#region virautl functions
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
#endregion


#region signals handlers
func _on_main_operated(operation: Types.Operation) -> void:
	if operation.element_id == id:
		pass
	else:
		_set_active(false)
#endregion


func init(scene: Node2D, position_: Vector2, operated: Signal) -> void:
	position = position_
	_instantiate(scene, operated)

func load(scene: Node2D, data: Dictionary, operated: Signal) -> void:
	id = data["id"]
	position = Vector2(data["position.x"], data["position.y"])
	init(scene, position, operated)

func save(file: FileAccess) -> void:
	var data := {
		"type": Constants.ElementType.VERTEX,
		"id": id,
		"position.x": position.x,
		"position.y": position.y
	}
	file.store_line(JSON.stringify(data))


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

	return super ()

func type() -> Constants.ElementType:
	return Constants.ElementType.VERTEX
