extends Node3D

@export var start_button: Button

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/scene.tscn")
