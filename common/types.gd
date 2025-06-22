class_name Types

enum OperationType {
	UNSPECIFIED = 0,
	CREATE,
	DELETE,
}

class Operation:
	var operation_type: OperationType
	var element_type: Constants.ElementType
	var element_id: int

	func _init(
		operation_type_: OperationType,
		element_type_: Constants.ElementType,
		element_id_: int,
	) -> void:
		operation_type = operation_type_
		element_type = element_type_
		element_id = element_id_
