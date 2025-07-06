class_name Utils

static func get_node_at(self_: CanvasItem, position: Vector2) -> Node:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = position
	query.collide_with_areas = true
	var nodes = self_.get_world_2d().get_direct_space_state().intersect_point(query, 1)

	if nodes.size() == 0:
		return null

	return nodes[0]["collider"].get_parent()

static func wait_one_frame(self_: Node) -> void:
	await self_.get_tree().process_frame

const MAX_UNSIGNED_SHORT := 2 ** 16
static func to_unsigned_short(num: int) -> PackedByteArray:
	if MAX_UNSIGNED_SHORT < num or num < 0:
		printerr("Invalid unsigned short value: %d" % num)
		return PackedByteArray([0, 0])

	var lo := num & 0xff
	var hi := (num >> 8) & 0xff
	# NOTE: little endian
	return PackedByteArray([lo, hi])
