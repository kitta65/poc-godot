extends Node2D

class_name Element

var id: int = 0

#region signal handlers
func _on_main_operated(_operation: Types.Operation) -> void:
	printerr("not implemented")

#endregion

func delete() -> Types.Operation:
	queue_free()
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
