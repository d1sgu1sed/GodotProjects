extends StaticBody2D
@export var pipe_width:int
@export var max_width:float = 300 
@export var min_width:float = 270 
var current_width: float

var Upper: Sprite2D
var Lower: Sprite2D
var UpperColl: CollisionShape2D
var LowerColl: CollisionShape2D
var offset_value: Vector2
var expired: bool
var hit_sound: AudioStreamPlayer

func _ready():
	Upper = $"Upper"
	Lower = $"Lower"
	UpperColl = $"Area2D/UpperColl"
	LowerColl = $"Area2D/LowerColl"
	hit_sound = $"HitSound"
	
	current_width = (Lower.position.y - 
		Lower.texture.get_height()*Lower.scale.y/2) - \
		(Upper.position.y + Upper.texture.get_height()*\
		Upper.scale.y/2)
	pipe_width = randi_range(min_width,max_width)
	offset_value = Vector2(0,(current_width-pipe_width)/2)
	Upper.position += offset_value
	UpperColl.position += offset_value
	Lower.position -= offset_value
	LowerColl.position -= offset_value
	expired = false


func _on_area_2d_body_entered(body):
	if body.name == "Player" and Global.is_game_over == 0:
		hit_sound.play()
		$"/root/Main".trigger_game_over()
