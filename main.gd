extends Node2D

@export var edge_scene: PackedScene

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var edge := edge_scene.instantiate()
		edge.position = event.position
		add_child(edge)
