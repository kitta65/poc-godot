extends Node2D

class_name Element

var id: int = 0
static var ids: Dictionary[int, WeakRef] = {}

#region static functions
static func export(file: FileAccess, format := "gltf") -> void:
	if format != "gltf":
		printerr("Unsupported export format: %s" % format)
		return

	var vertices: Array[Vertex] = []
	var faces: Array[Face] = []
	for key in ids.keys():
		var elm : Element = ids[key].get_ref()
		if elm == null:
			continue
		match elm.type():
			Constants.ElementType.VERTEX:
				vertices.append(elm)
			Constants.ElementType.FACE:
				faces.append(elm)
	var gltf := Gltf.new(vertices, faces)
	gltf.save(file)
#endregion


#region virtual functions
func _ready() -> void:
	while (
		id == 0
		or id in ids
	):
		id = randi()

	ids[id] = weakref(self)
#endregion


#region signal handlers
func _on_main_operated(_operation: Types.Operation) -> void:
	printerr("not implemented")

#endregion

func delete() -> Types.Operation:
	queue_free()
	ids.erase(id)
	return Types.Operation.new(
		Types.OperationType.DELETE,
		type(),
		id
	)

func _instantiate(scene: Node2D, operated: Signal) -> void:
	operated.connect(_on_main_operated)
	scene.add_child(self)

func save(_file: FileAccess) -> void:
	printerr("not implemented")

func type() -> Constants.ElementType:
	printerr("not implemented")
	return Constants.ElementType.UNSPECIFIED
