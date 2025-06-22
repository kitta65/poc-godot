extends Marker2D

@export var radius := 5.0
@export var deactivated_color := Color.WHITE
@export var activated_color := Color.ORANGE
var id: int = 0
var active: bool = false
@onready var clickable_shape = $ClickableArea/ClickableShape

func _ready() -> void:
	if clickable_shape.shape is CircleShape2D:
		clickable_shape.shape.radius = radius
	else:
		printerr("Expected CircleShape2D, got: %s" % clickable_shape.shape)

	id = Utils.generate_id(self)


func _process(_delta: float) -> void:
	pass

func _draw() -> void:
	var color := activated_color if active else deactivated_color
	draw_circle(Vector2.ZERO, radius, color)

func load(data: Dictionary) -> void:
	id = data["id"]
	position = Vector2(data["position.x"], data["position.y"])

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

func _on_clickable_area_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int,
) -> void:
	if (
		event is InputEventMouseButton
		and event.pressed
		and event.button_index == MOUSE_BUTTON_RIGHT
	):
		queue_free()

func _on_main_operated(operation: Types.Operation) -> void:
	if operation.element_id == id:
		pass
	else:
		_set_active(false)