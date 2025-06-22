extends Node2D
signal operated(operation)

@export var vertex_scene: PackedScene
@export var edge_scene: PackedScene
@export var save_file_path := "user://save_data.jsonl"

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.pressed
		and event.button_index == MOUSE_BUTTON_LEFT
	):
		_handle_left_click(event)
	elif (
		event is InputEventMouseButton
		and event.pressed
		and event.button_index == MOUSE_BUTTON_RIGHT
	):
		_handle_right_click(event)

func _handle_left_click(event: InputEventMouseButton):
	var node := Utils.get_node_at(self, event.position)
	if node == null:
		var vertex := vertex_scene.instantiate()
		vertex.init(self, event.position, operated)
	else:
		if node.has_method("interact"):
			var operation = node.interact() as Types.Operation
			if operation.element_type == Constants.ElementType.VERTEX:
				var vertices := get_tree().get_nodes_in_group("vertex")
				var actives := vertices.filter(func(v): return v.active)
				if actives.size() == 2:
					var edge := edge_scene.instantiate()
					edge.init(self, actives, operated)

			operated.emit(operation)

func _handle_right_click(event: InputEventMouseButton):
	var node := Utils.get_node_at(self, event.position)
	if node == null:
		return

	if node.has_method("delete"):
		var operation = node.delete() as Types.Operation
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
				vertex.load(self, json.data, operated)
			_:
				printerr("Unknown type in JSON: %s" % json.data["type"])
				break
