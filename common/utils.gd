class_name Utils

static func generate_id(self_: Node) -> int:
	var id := 0

	var nodes := self_.get_tree().get_nodes_in_group("save")
	while (
		id == 0
		or nodes.any(func(node: Node): return node != self_ and node.id == id)
	):
		id = randi()

	return id
