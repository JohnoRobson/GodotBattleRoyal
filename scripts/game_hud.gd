class_name GameHud 
extends Control

signal pause_button_pressed

func _on_pause_button_pressed():
	pause_button_pressed.emit()
