extends Node2D
@export var scene_path: String = "res://pipe.tscn"
var min_pipe_interval: float = 1
var max_pipe_interval: float = 2
var scroll_speed = Global.scroll_speed
var pipes = []
var viewport_size
var max_pipes = 11
var debug
var player: CharacterBody2D
var pipe_size = Vector2(0,0)
var game_over_scene: PackedScene
var timer :Timer
var scoretext : RichTextLabel
@onready var audioMix = $LoseSound

func _ready():
	timer = $Timer
	player = $Player
	Global.score = 0
	Global.is_game_started = 1
	scoretext = $Score
	scoretext.text = "Score: " + str(Global.score)
	viewport_size = get_viewport().get_visible_rect().size
	timer_start()

	game_over_scene = preload("res://Restart.tscn")
	

func _physics_process(delta):
	if Global.is_game_over == 0:
		for pipe in pipes:
			pipe.position.x -= scroll_speed * delta
			pipe_size = pipe.get_node("CollisionShape2D").shape.extents * 2
			if(player.position.x > pipe.position.x and pipe.expired == false):
				Global.score += 1
				pipe.expired = true
				scoretext.text = "Score: " + str(Global.score)
		for pipe in pipes:
			if pipe.position.x < -pipe_size.x:
				pipes.erase(pipe)
				pipe.queue_free()
			if pipes.size() >= max_pipes:
				var old_pipe = pipes.pop_front()
				old_pipe.queue_free()
	else:
		pass

func timer_start():
	timer.wait_time = max_pipe_interval
	timer.start()
	timer.timeout.connect(self.generate_pipe)

func generate_pipe():
	if pipes.size() < max_pipes:
		var pipe = load(scene_path).instantiate()
		pipe_size = pipe.get_node("CollisionShape2D").shape.extents * 2
		pipe.z_index = -1
		pipe.position = Vector2(viewport_size.x + pipe_size.x / 2, randi_range(-40,190))
		pipes.append(pipe)
		add_child(pipe)
	timer.set_wait_time(randf_range(min_pipe_interval,max_pipe_interval))

func trigger_game_over():
	
	audioMix.play()
	Global.is_game_over = 1
	Global.scroll_speed = 0
	Global.is_game_started = 0
	player.rotate(PI/2)
	timer.stop()
	var game_over_instance = game_over_scene.instantiate()
	add_child(game_over_instance)
	game_over_instance.z_index = 1
