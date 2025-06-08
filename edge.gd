extends Marker2D

@export var radius := 5
@export var color := Color.WHITE

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func to_save_data() -> Dictionary:
	return {
		"type": "edge",
		"position.x": position.x,
		"position.y": position.y
	}