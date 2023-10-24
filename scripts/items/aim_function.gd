extends Resource
class_name AimFunction

func aim_angle(target_global_position: Vector3, current_global_position: Vector3) -> Vector3:
	return target_global_position - current_global_position
