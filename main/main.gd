extends Node2D
signal operated(operation)

@export var vertex_scene: PackedScene
@export var edge_scene: PackedScene
@export var face_scene: PackedScene
@export var save_file_path := "user://save_data.jsonl"

#region virtual functions
func _ready() -> void:
	pass
#endregion

func _handle_left_click(event: InputEventMouseButton):
	var node := Utils.get_node_at(self, event.position)
	if node == null:
		var vertex := vertex_scene.instantiate()
		vertex.init(self, event.position, operated)
	else:
		if not node.has_method("interact"):
			return

		var operation = node.interact() as Types.Operation
		if operation.element_type == Constants.ElementType.VERTEX:
			var vertices := get_tree().get_nodes_in_group("vertex")
			var actives := vertices.filter(func(v): return v.active)
			if actives.size() != 2:
				return
			var edge := edge_scene.instantiate()
			edge.init(self, actives, operated)

		if operation.element_type == Constants.ElementType.EDGE:
			var edges := get_tree().get_nodes_in_group("edge")
			var actives := edges.filter(func(v): return v.active)
			if actives.size() != 3:
				return
			var vertices = []
			for edge in actives:
				if edge.start_vertex.get_ref().id not in vertices:
					vertices.append(edge.start_vertex.get_ref().id)
				if edge.end_vertex.get_ref().id not in vertices:
					vertices.append(edge.end_vertex.get_ref().id)
			if vertices.size() != 3:
				return
			var face := face_scene.instantiate()
			face.init(self, actives, operated)

		operated.emit(operation)

func _handle_right_click(event: InputEventMouseButton):
	var node := Utils.get_node_at(self, event.position)
	if node == null:
		return

	if node.has_method("delete"):
		var operation = node.delete() as Types.Operation
		operated.emit(operation)

func _on_load_button_pressed() -> void:
	# TODO: refactor to remove wait_one_frame
	# remove all elements
	var elements := get_tree().get_nodes_in_group("save")
	for elm in elements:
		elm.queue_free()
	await Utils.wait_one_frame(self) # wait for nodes to be removed

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
			Constants.ElementType.EDGE:
				var edge = edge_scene.instantiate()
				edge.load(self, json.data, operated)
			Constants.ElementType.FACE:
				var face = face_scene.instantiate()
				face.load(self, json.data, operated)
			_:
				printerr("Unknown type in JSON: %s" % json.data["type"])
				break

func _on_save_button_pressed() -> void:
	var file := FileAccess.open(save_file_path, FileAccess.WRITE)

	# NOTE: save order is important!
	for type in ["vertex", "edge", "face"]:
		var elements := get_tree().get_nodes_in_group(type)
		for element: Element in elements:
			element.save(file)

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
