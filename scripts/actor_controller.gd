class_name ActorController
extends Node3D

## Returns the position in global space that the controller is aiming at.
## For players, this is the mouse position in global space.
func get_aim_position() -> Vector3:
	return Vector3.ZERO

func get_move_direction() -> Vector2:
	return Vector2.ZERO

func is_shooting() -> bool:
	return false

func is_reloading() -> bool:
	return false

func is_exchanging_weapon() -> bool:
	return false
