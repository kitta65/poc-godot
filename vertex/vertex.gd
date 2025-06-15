extends Marker2D

@export var radius := 5.0
@export var color := Color.WHITE

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)

func _ready() -> void:
	var clickable_shape := $ClickableArea/ClickableShape

	if clickable_shape.shape is CircleShape2D:
		clickable_shape.shape.radius = radius
	else:
		printerr("Expected CircleShape2D, got: %s" % clickable_shape.shape)

func _process(_delta: float) -> void:
	pass

func to_save_data() -> Dictionary:
	return {
		"type": "vertex",
		"position.x": position.x,
		"position.y": position.y
	}


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
