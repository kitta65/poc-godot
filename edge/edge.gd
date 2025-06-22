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


func init(scene: Node2D, vertices: Array[Node], operated: Signal) -> void:
	if vertices.size() != 2:
		printerr("The size of vertices should be 2, got: %d" % vertices.size())
		return

	start_vertex = weakref(vertices[0])
	end_vertex = weakref(vertices[1])

	operated.connect(_on_main_operated)
	scene.add_child(self)


func _on_main_operated(_operation: Types.Operation) -> void:
	pass
