extends Node2D

@export var edge_scene: PackedScene
@export var save_file_path := "user://save_data.jsonl"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var edge := edge_scene.instantiate()
		edge.position = event.position
		add_child(edge)


func _on_save_button_pressed() -> void:
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)

	var nodes := get_tree().get_nodes_in_group("save")
	for node in nodes:
		if !node.has_method("to_save_data"):
			printerr("cannot save node: %s" % node.name)
			continue
		var data = node.to_save_data()
		var json := JSON.stringify(data)
		file.store_line(json)


func _on_load_button_pressed() -> void:
	# rm all nodes
	var nodes := get_tree().get_nodes_in_group("save")
	for node in nodes:
		node.queue_free()

	# TODO: error handling (what if the file doesn't exist?)
	var file = FileAccess.open(save_file_path, FileAccess.READ)
	for line in file.get_as_text().split("\n"):
		if line == "":
			break

		var json = JSON.new()
		var parse_result = json.parse(line)
		if not parse_result == OK:
			printerr("Failed to parse JSON: %s" % line)
			continue

		match json.data["type"]:
			"edge":
				var edge = edge_scene.instantiate()
				edge.position = Vector2(json.data["position.x"], json.data["position.y"])
				add_child(edge)
			_:
				printerr("Unknown type in JSON: %s" % json.data["type"])
				break
