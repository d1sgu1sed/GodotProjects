extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 800

@onready var animation = get_node('AnimationPlayer')
@onready var sprite = get_node('DudeSprite')

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED
	
	if Input.is_action_just_pressed('ui_up') and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if not is_on_floor():
		animation.play('jump')
	
	if direction != 0:
		sprite.flip_h = direction < 0
		animation.play('run')
	else:
		animation.play('idle')
	
	move_and_slide()
