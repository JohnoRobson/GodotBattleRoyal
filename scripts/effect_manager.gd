class_name EffectManager
extends Node3D

var bullet_effect = preload("res://scenes/effects/bullet_effect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_actor_shoot(start_position, end_position):
	var bullet = bullet_effect.instantiate()
	bullet.start = start_position
	bullet.end = end_position
	add_child(bullet)
