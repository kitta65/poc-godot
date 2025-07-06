class_name Gltf

var vertices: Array[Vector3] = []
var faces: Array[Vector3i] = []
const EMPTY = {
	"asset": {
		"version": "2.0"
	},
	"scene": 0,
	"scenes": [
		{"nodes": [0]}
	],
	"nodes": [
		{"mesh": 0}
	],
	"meshes": [
		{
			"primitives": []
		}
	],
	"buffers": [],
	"bufferViews": [],
	"accessors": [],
}

func _init(vertices_: Array[Vertex], faces_: Array[Face]) -> void:
	# NOTE: sort arrays to generate deterministic glTF
	vertices_.sort_custom(func(a, b): return a.id < b.id)
	faces_.sort_custom(func(a, b): return a.id < b.id)

	var idx = 0
	var id2idx: Dictionary[int, int] = {}
	for vertex in vertices_:
		id2idx[vertex.id] = idx
		idx += 1

	vertices.assign(vertices_.map(func(v): return Vector3(v.position.x, v.position.y, 0)))
	for f in faces_:
		var vertex_ids := f.vertices().map(func(v: Vertex): return v.id)
		var indices := vertex_ids.map(func(id: int): return id2idx[id])
		indices.sort()
		faces.append(Vector3i(indices[0], indices[1], indices[2]))

func save(file: FileAccess) -> void:
	var data := EMPTY.duplicate(true)
	if faces.size() == 0:
		file.store_line(JSON.stringify(data))
		return

	var indices := GltfIndices.new(faces)
	var position := GltfPosition.new(vertices)

	data["meshes"][0]["primitives"] = [
		{
			"attributes": {
				"POSITION": 1
			},
			"indices": 0
		}
	]

	data["buffers"] = [
		indices.buffer(),
		position.buffer()
	]

	data["bufferViews"] = [
		indices.bufferView(0),
		position.bufferView(1)
	]

	data["accessors"] = [
		indices.accessor(0),
		position.accessor(1)
	]

	file.store_line(JSON.stringify(data))


class GltfIndices:
	var faces: Array[Vector3i]
	var base64 := ""
	var max_value := 0

	func _init(faces_: Array[Vector3i]) -> void:
		faces = faces_
		var bytes = PackedByteArray()
		for face in faces:
			for idx in [face.x, face.y, face.z]:
				bytes.append_array(Utils.to_unsigned_short(idx))
				max_value = max(max_value, idx)
		base64 = Marshalls.raw_to_base64(bytes)

	func accessor(idx: int) -> Dictionary:
		return {
			"bufferView": idx,
			"byteOffset": 0,
			# see https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#accessor-data-types
			"componentType": 5123, # unsigned short
			"count": faces.size() * 3,
			"type": "SCALAR",
			"max": [max_value],
			"min": [0],
		}

	func buffer() -> Dictionary:
		return {
			"uri": "data:application/octet-stream;base64,%s" % base64,
			"byteLength": _byte_length(),
		}

	func bufferView(idx: int) -> Dictionary:
		return {
			"buffer": idx,
			"byteOffset": 0,
			"byteLength": _byte_length(),
			# see https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#_bufferview_target
			"target": 34963 # ELEMENT_ARRAY_BUFFER,
		}

	func _byte_length() -> int:
		return (
			2 # 16 bits / 8 bits = 2 bytes
			* faces.size()
			* 3 # num of vertices (face is triangle)
		)


class GltfPosition:
	var vertices: Array[Vector3]
	var base64 := ""
	var max_x: float
	var max_y: float
	var max_z: float
	var min_x: float
	var min_y: float
	var min_z: float

	func _init(vertices_: Array[Vector3]) -> void:
		vertices = vertices_
		var floats: Array[float] = []
		for i in range(vertices.size()):
			var v := vertices[i]
			if i == 0:
				max_x = v.x
				max_y = v.y
				max_z = v.z
				min_x = v.x
				min_y = v.y
				min_z = v.z
			else:
				max_x = max(max_x, v.x)
				max_y = max(max_y, v.y)
				max_z = max(max_z, v.z)
				min_x = min(min_x, v.x)
				min_y = min(min_y, v.y)
				min_z = min(min_z, v.z)
			floats.append_array([v.x, v.y, v.z])
		var packed_floats := PackedFloat32Array(floats)
		var bytes := packed_floats.to_byte_array()
		base64 = Marshalls.raw_to_base64(bytes)

	func accessor(idx: int) -> Dictionary:
		return {
			"bufferView": idx,
			"byteOffset": 0,
			# see https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#accessor-data-types
			"componentType": 5126, # float
			"count": vertices.size(),
			"type": "VEC3",
			"max": [max_x, max_y, max_z],
			"min": [min_x, min_y, min_z],
		}

	func buffer() -> Dictionary:
		return {
			"uri": "data:application/octet-stream;base64,%s" % base64,
			"byteLength": _byte_length(),
		}

	func bufferView(idx: int) -> Dictionary:
		return {
			"buffer": idx,
			"byteOffset": 0,
			"byteLength": _byte_length(),
			# see https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#_bufferview_target
			"target": 34962 # ARRAY_BUFFER,
		}

	func _byte_length() -> int:
		var bytes := (
			4 # 32 bits / 8 bits = 4 bytes
			* 3 # x, y, z
			* vertices.size()
		)
		return bytes
