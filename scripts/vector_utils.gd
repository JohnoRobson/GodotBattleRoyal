class_name VectorUtils
extends Object

static func make_local_inaccuracy_vector(degrees_of_inaccuracy: float) -> Vector3:
	# set up the inaccuracy and aim vector for the raycast
	var random = RandomNumberGenerator.new()
	var radians_of_inaccuracy_for_this_shot = deg_to_rad(random.randf_range(-degrees_of_inaccuracy / 2, degrees_of_inaccuracy / 2))
	var rotation_angle_of_inaccuracy_for_this_shot = random.randf_range(0.0, PI)
	# get the inaccuracy vector, which is only up and down inaccuracy
	var inaccuracy_vector = Vector3(0, sin(radians_of_inaccuracy_for_this_shot), -cos(radians_of_inaccuracy_for_this_shot))
	# rotate the inaccuracy vector by rotation_angle_of_inaccuracy_for_this_shot
	return inaccuracy_vector.rotated(Vector3.FORWARD, rotation_angle_of_inaccuracy_for_this_shot)