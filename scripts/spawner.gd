class_name Spawner extends Node3D

var used: bool = false

func _ready() -> void:
	hide()

func calculate_spawn_positions(number_of_points: int) -> Array[Vector3]:
	var positions: Array[Vector3] = []
	var cast_range: float = 10.0
	var cast_collision_mask: int = 0b0001 # 0001 world, 0010 actor
	
	var points: Array[Vector3] = VectorUtils.get_radially_symmetrical_points(Vector3.ZERO, number_of_points, 2)
	for point in points:
		var raycast_start_position = self.to_global(point)
		var raycast_end_position = self.to_global(point + Vector3.DOWN * cast_range)
		var query = PhysicsRayQueryParameters3D.create(raycast_start_position, raycast_end_position, cast_collision_mask)
		query.collide_with_areas = true
		query.collide_with_bodies = true
		
		var space_state = self.get_world_3d().direct_space_state
		positions.append(space_state.intersect_ray(query).position)
	
	return positions
