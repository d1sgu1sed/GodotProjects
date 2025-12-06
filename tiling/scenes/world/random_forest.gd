extends Node2D

enum RandomType {Random, Perlin}

@export var size: Vector2i = Vector2i(10, 10)

@export var random_type: RandomType = RandomType.Random
@onready var water: TileMapLayer = $Water
@onready var ground: TileMapLayer = $Ground
@onready var trees: TileMapLayer = $Trees

var ground_tiles = {
	"ground": Vector2i(1, 1)
}

var tree_tiles = {
	"small_tree": Vector2i(0, 0),
	"big_tree": Vector2i(1, 0),
	"apple_tree": Vector2i(3, 0),
}

func _ready() -> void:
	for x in range(-1, size.x + 2, 1):
		water.set_cell(Vector2i(x, -1), 0, Vector2i(0, 0))
		water.set_cell(Vector2i(x, size.y + 1), 0, Vector2i(0, 0))
		
	for y in range(-1, size.y + 2, 1):
		water.set_cell(Vector2i(-1, y), 0, Vector2i(0, 0))
		water.set_cell(Vector2i(size.x + 1, y), 0, Vector2i(0, 0))
	
	match random_type:
		RandomType.Random:
			_random()
		RandomType.Perlin:
			_perlin()
	
func _random():
	for x in size.x + 1:
		for y in size.y + 1:
			var tile: Vector2i = Vector2i(-1, -1)
			var tile_pos = Vector2i(x, y)
			if randf() < 0.8:
				tile = ground_tiles["ground"]
				if randf() < 0.1:
					var tree_types: Array = tree_tiles.keys()
					var tree_type: int = randi_range(0, tree_tiles.size() - 1)
					var tree = tree_tiles[tree_types[tree_type]]
					trees.set_cell(tile_pos + Vector2i(0, -1), 0, tree)
			if tile != Vector2i(-1, -1):
				ground.set_cell(tile_pos, 0, tile)
			else:
				water.set_cell(tile_pos, 0, Vector2i(0, 0))

func _perlin():
	var noise = FastNoiseLite.new()
	noise.frequency = 0.0
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3
	noise.fractal_lacunarity
	noise.fractal_gain = 1
