extends Node2D
signal operated(operation)

@export var vertex_scene: PackedScene
@export var save_file_path := "user://save_data.jsonl"

func _unhandled_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.pressed
		and event.button_index == MOUSE_BUTTON_LEFT
	):
		_handle_left_click(event)

func _handle_left_click(event: InputEventMouseButton):
	var query := PhysicsPointQueryParameters2D.new()
	query.position = event.position
	query.collide_with_areas = true
	var nodes = get_world_2d().get_direct_space_state().intersect_point(query, 1)

	if nodes.size() == 0:
		var vertex := vertex_scene.instantiate()
		vertex.position = event.position
		operated.connect(vertex._on_main_operated)
		add_child(vertex)
	else:
		# TODO: get_parent() is not sophisticated
		var node: Node = nodes[0]["collider"].get_parent()
		if node.has_method("interact"):
			var id = node.interact()
			# TODO: if two vertices are active, it's time to instantiate a new edge

			var operation = Types.Operation.new(Types.OperationType.UNSPECIFIED, id)
			operated.emit(operation)

func _on_save_button_pressed() -> void:
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)

	var nodes := get_tree().get_nodes_in_group("save")
	for node in nodes:
		if !node.has_method("save"):
			printerr("cannot save node: %s" % node.name)
			continue
		var data = node.save()
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

		match json.data["type"] as int:
			Constants.ElementType.VERTEX:
				var vertex = vertex_scene.instantiate()
				vertex.load(json.data)
				operated.connect(vertex._on_main_operated)
				add_child(vertex)
			_:
				printerr("Unknown type in JSON: %s" % json.data["type"])
				break
