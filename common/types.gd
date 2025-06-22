class_name Types

enum OperationType {
	UNSPECIFIED = 0,
}

class Operation:
	var type: OperationType
	var target: int

	func _init(type_: OperationType, target_: int) -> void:
		type = type_
		target = target_
