extends Marker2D

@export var radius := 5.0
@export var deactivated_color := Color.WHITE
@export var activated_color := Color.ORANGE
var id: int = 0
var activated: bool = false

func _ready() -> void:
	var clickable_shape := $ClickableArea/ClickableShape

	if clickable_shape.shape is CircleShape2D:
		clickable_shape.shape.radius = radius
	else:
		printerr("Expected CircleShape2D, got: %s" % clickable_shape.shape)

	# generate unique ID
	var vertices := get_tree().get_nodes_in_group("vertex")
	while (
		id == 0
		or vertices.any(func(node: Node): return node != self and node.id == id)
	):
		id = randi()


func _process(_delta: float) -> void:
	pass

func _draw() -> void:
	var color := activated_color if activated else deactivated_color
	draw_circle(Vector2.ZERO, radius, color)

func load(data: Dictionary) -> void:
	id = data["id"]
	position = Vector2(data["position.x"], data["position.y"])

func save() -> Dictionary:
	return {
		"type": "vertex",
		"id": id,
		"position.x": position.x,
		"position.y": position.y
	}

func _toggle_activated() -> void:
	activated = not activated
	queue_redraw()

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

	elif (
		event is InputEventMouseButton
		and event.pressed
		and event.button_index == MOUSE_BUTTON_LEFT
	):
		_toggle_activated()