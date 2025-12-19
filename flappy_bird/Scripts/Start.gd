extends Node2D
var scroll_speed = Global.scroll_speed
var viewport_size
var player: CharacterBody2D
var main_scene: PackedScene
var sine_counter:int = 0

var swing_amplitude: float = 10.0
var swing_frequency: float = 2
var base_y: float
@onready var AudioMix = $Soundtrack

func _ready():
	player = $Player
	viewport_size = get_viewport().get_visible_rect().size
	main_scene = preload("res://main.tscn")
	player.gravity = 0
	base_y = 526
	AudioMix.play()

func _physics_process(delta):
	if Global.is_game_over == 0 and Global.is_game_started == 0:
		if sine_counter > 100:
			sine_counter = 0
		else:
			sine_counter += 1
		apply_swinging_motion(sine_counter)
	else:
		pass
func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		start_game()

func start_game():
	AudioMix.stop()
	get_tree().change_scene_to_packed(main_scene)
	Global.is_game_started = 1
	
func apply_swinging_motion(counter:int) -> void:
	player.position.y = base_y + swing_amplitude * sin((counter*PI/50) * swing_frequency)
