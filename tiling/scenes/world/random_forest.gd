extends Node2D

enum RandomType { Random, Perlin }

@export var size: Vector2i = Vector2i(10, 10)
@export var random_type: RandomType = RandomType.Random

@export var min_island_area: int = 25

@export var bridge_atlas: Vector2i = Vector2i(0, 1)

@onready var water: TileMapLayer = $Water
@onready var ground: TileMapLayer = $Ground
@onready var trees: TileMapLayer = $Trees
@onready var bridge: TileMapLayer = $Bridge

var ground_tiles = {
	"ground": Vector2i(1, 1)
}

var tree_tiles = {
	"small_tree": Vector2i(0, 0),
	"big_tree": Vector2i(1, 0),
	"apple_tree": Vector2i(3, 0),
}

func _ready() -> void:
	for x in range(-1, size.x + 2):
		water.set_cell(Vector2i(x, -1), 0, Vector2i(0, 0))
		water.set_cell(Vector2i(x, size.y + 1), 0, Vector2i(0, 0))

	for y in range(-1, size.y + 2):
		water.set_cell(Vector2i(-1, y), 0, Vector2i(0, 0))
		water.set_cell(Vector2i(size.x + 1, y), 0, Vector2i(0, 0))

	match random_type:
		RandomType.Random:
			_generate_random_with_bridges()
		RandomType.Perlin:
			_generate_perlin_with_bridges()

func _generate_random_with_bridges() -> void:
	var map := _make_empty_map()
	for x in range(size.x + 1):
		for y in range(size.y + 1):
			map[y][x] = 1 if (randf() < 0.8) else 0

	_connect_islands_with_bridges(map)
	_render_map(map)

	for x in range(size.x + 1):
		for y in range(size.y + 1):
			if map[y][x] == 1 and randf() < 0.1:
				var tree_types: Array = tree_tiles.keys()
				var tree_type: int = randi_range(0, tree_tiles.size() - 1)
				var tree_atlas: Vector2i = tree_tiles[tree_types[tree_type]]
				trees.set_cell(Vector2i(x, y) + Vector2i(0, -1), 0, tree_atlas)

func _generate_perlin_with_bridges() -> void:
	var noise = FastNoiseLite.new()
	noise.frequency = 0.05
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3
	noise.fractal_lacunarity = 2
	noise.fractal_gain = 1
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

	var map := _make_empty_map()
	for x in range(size.x + 1):
		for y in range(size.y + 1):
			var val = noise.get_noise_2d(x, y)
			map[y][x] = 1 if (val > 0.0) else 0

	_connect_islands_with_bridges(map)
	_render_map(map)

func _make_empty_map() -> Array:
	var map: Array[Array] = []
	for y in range(size.y + 1):
		map.append([])
		map[y].resize(size.x + 1)
		for x in range(size.x + 1):
			map[y][x] = 0
	return map

func _connect_islands_with_bridges(map: Array) -> void:
	var lbl := label(map)
	
	_remove_islands_in_place(map, lbl, min_island_area)

	var ids := _get_unique_labels(lbl)
	while ids.size() > 1:
		_build_bridge_between(map, lbl, ids[0], ids[1])
		lbl = label(map)
		ids = _get_unique_labels(lbl)

func label(input_map: Array) -> Array:
	var h = input_map.size()
	if h == 0:
		return []
	var w = input_map[0].size()

	var labels: Array = []
	labels.resize(h)
	for y in range(h):
		labels[y] = []
		labels[y].resize(w)
		for x in range(w):
			labels[y][x] = 0

	var neighbors_4 = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]
	var neighbors_8 = neighbors_4 + [
		Vector2i(1, 1),
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(-1, -1),
	]
	var neighbors = neighbors_8

	var current_label = 0

	for y in range(h):
		for x in range(w):
			if input_map[y][x] != 0 and labels[y][x] == 0:
				current_label += 1
				var stack: Array[Vector2i] = [Vector2i(x, y)]
				labels[y][x] = current_label

				while stack.size() > 0:
					var p = stack.pop_back()
					for d in neighbors:
						var nx = p.x + d.x
						var ny = p.y + d.y
						if nx < 0 or ny < 0 or nx >= w or ny >= h:
							continue
						if input_map[ny][nx] != 0 and labels[ny][nx] == 0:
							labels[ny][nx] = current_label
							stack.append(Vector2i(nx, ny))

	return labels

func _remove_islands_in_place(map: Array, labels: Array, min_area: int) -> void:
	var h = labels.size()
	if h == 0:
		return
	var w = labels[0].size()

	var area := {}
	for y in range(h):
		for x in range(w):
			var l: int = labels[y][x]
			if l > 0:
				area[l] = area.get(l, 0) + 1

	var keep := {}
	for l in area.keys():
		if area[l] >= min_area:
			keep[l] = true

	for y in range(h):
		for x in range(w):
			var l: int = labels[y][x]
			if l > 0 and not keep.has(l):
				labels[y][x] = 0
				map[y][x] = 0

func _get_unique_labels(label_map: Array) -> Array[int]:
	var seen := {}
	var out: Array[int] = []
	for y in range(label_map.size()):
		for x in range(label_map[y].size()):
			var l := int(label_map[y][x])
			if l > 0 and not seen.has(l):
				seen[l] = true
				out.append(l)
	out.sort()
	return out

func _get_points(label_map: Array, label_id: int) -> Array[Vector2i]:
	var pts: Array[Vector2i] = []
	for y in range(label_map.size()):
		for x in range(label_map[y].size()):
			if int(label_map[y][x]) == label_id:
				pts.append(Vector2i(x, y))
	return pts

func _build_bridge_between(map: Array, label_map: Array, label1: int, label2: int) -> void:
	var points1 := _get_points(label_map, label1)
	var points2 := _get_points(label_map, label2)
	if points1.is_empty() or points2.is_empty():
		return

	var min_dist := INF
	var min_p1 := points1[0]
	var min_p2 := points2[0]

	for p1 in points1:
		for p2 in points2:
			var dist := p1.distance_to(p2)
			if dist < min_dist:
				min_dist = dist
				min_p1 = p1
				min_p2 = p2

	var line: Array = Geometry2D.bresenham_line(min_p1, min_p2)
	var prev: Vector2i = line[0]
	for p in line:
		map[p.y][p.x] = -1
		if prev.x != p.x and prev.y != p.y:
			map[prev.y][p.x] = -1
		prev = p

func _render_map(map: Array) -> void:
	for x in range(size.x + 1):
		for y in range(size.y + 1):
			var pos := Vector2i(x, y)
			match int(map[y][x]):
				1:
					ground.set_cell(pos, 0, ground_tiles["ground"])
				-1:
					bridge.set_cell(pos, 0, bridge_atlas)
				_:
					water.set_cell(pos, 0, Vector2i(0, 0))

func _place_character(character: CharacterBody2D):
	while true:
		var x = randi_range(0, size.x)
		var y = randi_range(0, size.y)
		var pos = Vector2i(x, y)
		var tile = ground.get_cell_atlas_coords(pos)
		if tile != Vector2i(-1, -1):
			character.global_position = ground.map_to_local(pos)
			break
