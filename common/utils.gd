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

static func get_node_at(self_: CanvasItem, position: Vector2) -> Node:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = position
	query.collide_with_areas = true
	var nodes = self_.get_world_2d().get_direct_space_state().intersect_point(query, 1)

	if nodes.size() == 0:
		return null

	return nodes[0]["collider"].get_parent()
