class_name Gltf

var vertices: Array[Vector3] = []
var faces: Array[Vector3i] = []
const EMPTY = {
	"asset": {
		"version": "2.0"
	},
	"scene": 0,
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
		indices.accessor(0, faces.size()),
		position.accessor(1)
	]

	file.store_line(JSON.stringify(data))


class GltfIndices:
	var faces: Array[Vector3i]

	func _init(faces_: Array[Vector3i]) -> void:
		faces = faces_

	func accessor(idx: int, max_: int) -> Dictionary:
		return {
			"bufferView": idx,
			"byteOffset": 0,
			# see https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#accessor-data-types
			"componentType": 5123, # unsigned short
			"count": faces.size(),
			"type": "SCALAR",
			"max": [max_],
			"min": [0],
		}

	func buffer() -> Dictionary:
		return {
			"uri": "data:application/octet-stream;base64,", # TODO
			"byteLength": 0, # TODO
		}

	func bufferView(idx: int) -> Dictionary:
		return {
			"buffer": idx,
			"byteOffset": 0,
			"byteLength": 0, # TODO
			# see https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#_bufferview_target
			"target": 34962 # ARRAY_BUFFER
		}


class GltfPosition:
	var vertices: Array[Vector3]

	func _init(vertices_: Array[Vector3]) -> void:
		vertices = vertices_

	func accessor(idx: int) -> Dictionary:
		return {
			"bufferView": idx,
			"byteOffset": 0,
			# see https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#accessor-data-types
			"componentType": 5126, # float
			"count": vertices.size(),
			"type": "VEC3",
			"max": [1.0, 1.0, 0.0], # TODO
			"min": [0.0, 0.0, 0.0], # TODO
		}

	func buffer() -> Dictionary:
		return {
			"uri": "data:application/octet-stream;base64,", # TODO
			"byteLength": 0, # TODO
		}

	func bufferView(idx: int) -> Dictionary:
		return {
			"buffer": idx,
			"byteOffset": 0,
			"byteLength": 0, # TODO
			# see https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#_bufferview_target
			"target": 34963 # ELEMENT_ARRAY_BUFFER
		}
