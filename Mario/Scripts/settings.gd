extends Control

@onready var close_button = $MarginContainer/VBoxContainer/Button
@onready var slider = $MarginContainer/VBoxContainer/HSlider

signal exit_settings_menu

func _ready() -> void:
	slider.value = 10
	set_process(false)

func _on_h_slider_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(bus, value)

func _on_button_pressed() -> void:
	exit_settings_menu.emit()
	set_process(false)
