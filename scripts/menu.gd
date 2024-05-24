class_name Menu extends Control

signal start_game_button_pressed
signal return_to_title_button_pressed
signal settings_button_pressed
signal back_button_pressed

func _on_start_button_pressed():
	start_game_button_pressed.emit()

func _on_return_to_title_button_pressed():
	return_to_title_button_pressed.emit()

func _on_settings_button_pressed():
	settings_button_pressed.emit()

func _on_back_button_pressed():
	back_button_pressed.emit()
