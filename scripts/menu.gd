class_name Menu
extends Control

signal start_game_button_pressed(game_type: World.GameTypes)
signal restart_game_button_pressed()
signal return_to_title_button_pressed()
signal settings_button_pressed()
signal back_button_pressed()
signal close_button_pressed()
signal resume_button_pressed()

func _on_start_button_pressed(game_type: World.GameTypes) -> void:
	start_game_button_pressed.emit(game_type)

func _on_restart_button_pressed() -> void:
	restart_game_button_pressed.emit()

func _on_return_to_title_button_pressed() -> void:
	return_to_title_button_pressed.emit()

func _on_settings_button_pressed() -> void:
	settings_button_pressed.emit()

func _on_back_button_pressed() -> void:
	back_button_pressed.emit()

func _on_close_button_pressed() -> void:
	close_button_pressed.emit()

func _on_resume_button_pressed() -> void:
	resume_button_pressed.emit()
