extends Line2D

@export var deactivated_color := Color.WHITE
@export var activated_color := Color.ORANGE
@export var line_width := 3.0
var start_vertex: WeakRef
var end_vertex: WeakRef

func _ready() -> void:
	default_color = deactivated_color
	width = line_width
	points = [
		start_vertex.get_ref().position,
		end_vertex.get_ref().position,
	]

func _process(_delta: float) -> void:
	pass
