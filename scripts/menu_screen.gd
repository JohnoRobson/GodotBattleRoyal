class_name MenuScreen extends Control

signal start_game_pressed
signal return_to_title_pressed

func _on_start_button_pressed():
	start_game_pressed.emit()

func _on_return_to_title_pressed():
	return_to_title_pressed.emit()
