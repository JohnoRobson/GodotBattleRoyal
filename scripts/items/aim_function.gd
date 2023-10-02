extends Resource

class_name AimFunction

@export var projectile_velocity: float

func aim_angle(distance_to_target: float, target_global_position: Vector3, current_global_position: Vector3) -> Vector3:
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	var altitude = target_global_position.y - current_global_position.y
	var top = pow(projectile_velocity, 2) - sqrt(pow(projectile_velocity, 4) - gravity * (gravity * pow(distance_to_target, 2) + 2 * altitude * pow(projectile_velocity, 2)))
	var angle = atan(top / (gravity * distance_to_target))

	if is_nan(top):
		angle = PI / 4
	
	var opposite:float = distance_to_target * tan(angle)
	var direction_vec = target_global_position - current_global_position

	return Vector3(direction_vec.x, opposite, direction_vec.z)
