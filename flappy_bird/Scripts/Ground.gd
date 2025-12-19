extends Sprite2D

var scroll_speed = Global.scroll_speed 

@export var tile_width: float = 85

var xoffset: float = 0.0
var start_pos: float

func _ready():
	xoffset = position.x
	start_pos = position.x

func _physics_process(delta: float) -> void:
	if Global.is_game_over == 0:
		xoffset -= scroll_speed * delta

	if start_pos - xoffset >= tile_width:
		xoffset = start_pos

	position.x = xoffset
