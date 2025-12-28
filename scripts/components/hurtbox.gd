class_name Hurtbox
extends Area3D

@export var health: Health

signal was_hit(amount: float, hit_position_global: Vector3, hit_normalized_direction: Vector3)

func take_damage(amount: float, hit_position_global: Vector3, hit_normalized_direction: Vector3):
	was_hit.emit(amount, hit_position_global, hit_normalized_direction)
	
	if health != null:
		health.take_damage(amount)
