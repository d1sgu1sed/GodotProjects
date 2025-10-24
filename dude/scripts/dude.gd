extends Node2D

@onready var animation = get_node('AnimationPlayer')
@onready var sprite = get_node('DudeSprite')

var state: String = 'idle'

func _process(delta: float) -> void:
	if state == 'idle' and animation.current_animation != 'idle':
		animation.play('idle')
	if state == 'double_jump' and animation.current_animation != 'double_jump':
		animation.play('double_jump')
	if state == 'run' and animation.current_animation != 'run':
		animation.play('run')
		
	if Input.is_action_pressed("ui_up"):
		state = 'double_jump'
	elif Input.is_action_pressed("ui_left"):
		state = 'run'
		sprite.flip_h = true
	elif Input.is_action_pressed("ui_right"):
		state = 'run'
		sprite.flip_h = false
	else:
		state = 'idle'
	
	print(state)
