extends Node2D

@export var complexity: float = 0.75
@export var density: float = 0.75
@export var size: Vector2i = Vector2i(70, 70)

@onready var water: TileMapLayer = $Water
@onready var ground: TileMapLayer = $Ground
@onready var teleport: Node2D = $Teleport
@onready var treasure: Node2D = $Treasure

var map: Array[Array] = []
var labels_map: Array = []
var largest_label: int = 0

func _ready() -> void:
	GameWorld.treasure_found = false

	map = _generate_maze_map()
	_draw_map(map)

	labels_map = label(map)
	largest_label = _find_largest_label(labels_map)

func _draw_map(input_map: Array) -> void:
	for y in range(size.y):
		for x in range(size.x):
			var pos = Vector2i(x, y)
			if input_map[y][x] == 1:
				ground.set_cell(pos, 0, Vector2i(1, 1))
			else:
				water.set_cell(pos, 0, Vector2i(x % 4, 0))

func _generate_maze_map() -> Array[Array]:
	var out: Array[Array] = []
	out.resize(size.y)
	for y in range(size.y):
		out[y] = []
		out[y].resize(size.x)
		for x in range(size.x):
			out[y][x] = 0

	var scale_density: int = int(floor(density * floor(size.x / 2.0) * floor(size.y / 2.0)))
	var scale_complexity: int = int(floor(complexity * 5.0 * (size.x + size.y)))

	for i in range(scale_density):
		var x_rand: int = randi_range(0, int(floor(size.x / 2.0))) * 2 + 1
		var y_rand: int = randi_range(0, int(floor(size.y / 2.0))) * 2 + 1

		if x_rand >= size.x or y_rand >= size.y:
			continue

		out[y_rand][x_rand] = 1

		for j in range(scale_complexity):
			var neighbours: Array[Vector2i] = []

			if x_rand > 1:
				neighbours.append(Vector2i(x_rand - 2, y_rand))
			if x_rand < size.x - 2:
				neighbours.append(Vector2i(x_rand + 2, y_rand))
			if y_rand > 1:
				neighbours.append(Vector2i(x_rand, y_rand - 2))
			if y_rand < size.y - 2:
				neighbours.append(Vector2i(x_rand, y_rand + 2))

			if neighbours.is_empty():
				break

			var next: Vector2i = neighbours[randi_range(0, neighbours.size() - 1)]
			var xn = next.x
			var yn = next.y

			if out[yn][xn] == 0:
				out[yn][xn] = 1

				var dx = int(xn + floor((x_rand - xn) / 2.0))
				var dy = int(yn + floor((y_rand - yn) / 2.0))
				out[dy][dx] = 1

				x_rand = xn
				y_rand = yn

	return out

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

	var neighbors = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]

	var current_label = 0

	for y in range(h):
		for x in range(w):
			if input_map[y][x] != 0 and labels[y][x] == 0:
				current_label += 1
				var stack: Array[Vector2i] = []
				stack.append(Vector2i(x, y))
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

func _find_largest_label(lbl: Array) -> int:
	var h = lbl.size()
	if h == 0:
		return 0
	var w = lbl[0].size()

	var area = {}
	for y in range(h):
		for x in range(w):
			var l: int = int(lbl[y][x])
			if l > 0:
				area[l] = area.get(l, 0) + 1

	var best_label = 0
	var best_area = 0
	for l in area.keys():
		if int(area[l]) > best_area:
			best_area = int(area[l])
			best_label = int(l)

	return best_label

func _pick_random_ground_cell(require_largest_island: bool, avoid_world_pos: Vector2 = Vector2.INF, min_world_dist: float = 2.0) -> Vector2i:
	var tries = 0
	var max_tries = 100000

	while tries < max_tries:
		tries += 1

		var x = randi_range(0, size.x - 1)
		var y = randi_range(0, size.y - 1)
		var pos = Vector2i(x, y)

		if ground.get_cell_atlas_coords(pos) == Vector2i(-1, -1):
			continue

		if require_largest_island and largest_label != 0:
			if labels_map[y][x] != largest_label:
				continue

		if avoid_world_pos != Vector2.INF:
			var world_pos = ground.map_to_local(pos)
			if world_pos.distance_to(avoid_world_pos) < min_world_dist:
				continue

		return pos

	for yy in range(size.y):
		for xx in range(size.x):
			var p = Vector2i(xx, yy)
			if ground.get_cell_atlas_coords(p) != Vector2i(-1, -1):
				if require_largest_island and largest_label != 0 and labels_map[yy][xx] != largest_label:
					continue
				return p

	return Vector2i(0, 0)


func _place_objects_on_largest_island(character: CharacterBody2D) -> void:
	var p1 = _pick_random_ground_cell(true)
	character.global_position = ground.map_to_local(p1)

	var p2 = _pick_random_ground_cell(true, character.global_position, 64.0)
	teleport.global_position = ground.map_to_local(p2)

	var p3 = _pick_random_ground_cell(true, character.global_position, 64.0)
	treasure.global_position = ground.map_to_local(p3)

func _place_character(character: CharacterBody2D):
	_place_objects_on_largest_island(character)
