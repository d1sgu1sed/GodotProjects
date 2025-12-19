extends Control

func _on_restart_button_pressed() -> void:
	restart_game()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEvent and event.is_action_pressed("ui_accept"):
		restart_game()

func restart_game() -> void:
	Global.is_game_over = 0
	Global.scroll_speed = 210
	get_tree().reload_current_scene()
