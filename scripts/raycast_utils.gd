class_name RaycastUtils
extends Object

static func raycast_in_direction(node: Node3D, start_position: Vector3, end_position: Vector3) -> Vector3:
	var cast_collision_mask: int = 0b0001 # 0001 world, 0010 actor
	
	var space_state = node.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(start_position, end_position, cast_collision_mask)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		RoyalLogger.warn("Raycast failed")
		return start_position
	else:
		return result.position

static func get_position_on_the_ground(node: Node3D, pos: Vector3) -> Vector3:
	var new_item_position_on_ground = raycast_in_direction(node, pos, pos + Vector3.DOWN * 100)
	return new_item_position_on_ground

static func get_position_in_direction_and_on_the_ground(node: Node3D, starting_position: Vector3, desired_position: Vector3) -> Vector3:
	var new_item_position_horizontal = raycast_in_direction(node, starting_position, desired_position)
	var new_item_position_on_ground = get_position_on_the_ground(node, new_item_position_horizontal)
	
	return new_item_position_on_ground
