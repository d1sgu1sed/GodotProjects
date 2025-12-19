extends Control

signal end_pause

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if has_node("ColorRect"):
		($ColorRect as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		_on_resume_pressed()

func _on_resume_pressed() -> void:
	end_pause.emit()
	set_process(false)


func _on_back_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
