extends Node

@onready var audioMix = $AudioStreamPlayer
@onready var pause_scene = $PauseLayer/Pause

func _ready() -> void:
	audioMix.play()
	
	if pause_scene and pause_scene.has_signal("end_pause"):
		var cb = Callable(self, "_on_pause_end_pause")
		if not pause_scene.end_pause.is_connected(cb):
			pause_scene.end_pause.connect(cb)
			
	if pause_scene:
		pause_scene.process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		_on_pause_button_pressed()
		
func _on_pause_button_pressed() -> void:
	if get_tree().paused:
		return
	pause_scene.visible = true
	pause_scene.set_process(true)
	get_tree().paused = true
	
func _on_pause_end_pause() -> void:
	get_tree().paused=false
	pause_scene.visible=false
	pause_scene.set_process(false)
