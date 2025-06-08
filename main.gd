extends Node2D

@export var edge_scene: PackedScene
@export var save_file_path := "user://save_data.jsonl"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var edge := edge_scene.instantiate()
		edge.position = event.position
		add_child(edge)


func _on_save_button_pressed() -> void:
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)

	var nodes := get_tree().get_nodes_in_group("save")
	for node in nodes:
		if !node.has_method("to_save_data"):
			printerr("cannot save node: %s" % node.name)
			continue
		var data = node.to_save_data()
		var json := JSON.stringify(data)
		save_file.store_line(json)
