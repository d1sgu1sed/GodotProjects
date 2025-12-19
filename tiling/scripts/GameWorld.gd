extends Node

@onready var levels = {
	"meadow": "res://scenes/world/meadow.tscn",
	"random_forest": "res://scenes/world/forest.tscn",
	"maze": "res://scenes/world/maze.tscn"
}

var world: Node2D = null
var player: CharacterBody2D = null
var current_level: Node2D = null
var treasure_found = false

func _set_world(node: Node2D):
	world = node
	
func _set_player(character: CharacterBody2D):
	player = character

func _load_level(name: String):
	if current_level:
		# Можно спрятать, а не выключать
		world.remove_child(current_level)
		current_level.queue_free()
	var node: Node2D = load(levels[name]).instantiate()
	current_level = node
	if world:
		world.add_child(current_level)
	if player:
		current_level._place_character(player)
