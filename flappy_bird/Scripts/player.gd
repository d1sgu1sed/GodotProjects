extends CharacterBody2D

@export var gravity_multiplier: float = 1.5
var gravity
var input: Vector2
var min_speed = 500
var max_speed = 700
var bird_anime: AnimationPlayer
var viewport_mid: Vector2
var max_rotation_up: float = -0.3
var max_rotation_down: float = 0.4
var rotation_speed: float = 20.0
var fly_sound: AudioStreamPlayer

func _ready():	
	bird_anime = $AnimationPlayer
	bird_anime.play("fly")
	viewport_mid = Vector2(get_viewport().get_visible_rect().size.x/2,get_viewport().get_visible_rect().size.y/3)
	position = viewport_mid
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravity_multiplier
	fly_sound = $"FlySound"

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if Global.is_game_over == 0 and Global.is_game_started == 1:
		player_movement(delta)
		velocity.x = 0
		rotate_bird(delta)
	if Global.is_game_over == 1 and is_on_floor():
		bird_anime.stop()
	move_and_slide()
	
func player_movement(delta):
	input = get_input()
	if input == Vector2.ZERO:
		pass
	else:
		velocity += (input*delta)
		velocity = velocity.limit_length(max_speed)
		if velocity.y >= -min_speed:
			velocity.y = -min_speed
		if not fly_sound.playing:
			fly_sound.play()

func get_input():
	input.y = int(Input.is_action_just_pressed("ui_up"))
	return input.normalized()

# Function to apply rotation logic
func rotate_bird(delta: float) -> void:
	if velocity.y < 0:
		rotation = lerp(rotation, max_rotation_up, rotation_speed * delta)
	else:
		rotation = lerp(rotation, max_rotation_down, rotation_speed * delta)
