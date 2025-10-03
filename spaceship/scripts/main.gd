extends Node2D

@onready var player = get_node("Player")
@onready var obstacle = get_node("Obstacle/AsteroidArea")
@onready var enemy = get_node("Enemy")
@onready var label = get_node("ShipLabel")


func _ready() -> void:
	player.damaged.connect(player.damage)
	#enemy.apply_force(Vector2(-300, 500))

func _process(delta: float) -> void:
	label.text = "Position %v" % player.global_position
	label.position = player.global_position + Vector2(-70, -80)
	enemy.seek(player.global_position)
	enemy.flee(obstacle.global_position)
