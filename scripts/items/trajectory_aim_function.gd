class_name TrajectoryAiming
extends AimFunction

@export var projectile_velocity: float

# This calculates a ballistic trajectory for a projectile with speed projectile_velocity.
# It returns a local point that is above the target_global_position such that when the projectile is aimed at that point and launched, it will hit the target.
# Or, if it cannot hit the target because it is out of range, it will just aim at a 45 degree angle pointing at the target, which gives the furthest distance possible.
func aim_angle(target_global_position: Vector3, current_global_position: Vector3) -> Vector3:
	var distance_to_target = target_global_position.distance_to(current_global_position)
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	var altitude = target_global_position.y - current_global_position.y
	var top = pow(projectile_velocity, 2) - sqrt(pow(projectile_velocity, 4) - gravity * (gravity * pow(distance_to_target, 2) + 2 * altitude * pow(projectile_velocity, 2)))
	var angle = atan(top / (gravity * distance_to_target))

	if is_nan(top):
		angle = PI / 4
	
	var opposite:float = distance_to_target * tan(angle)
	var direction_vec = target_global_position - current_global_position

	return Vector3(direction_vec.x, opposite, direction_vec.z)
