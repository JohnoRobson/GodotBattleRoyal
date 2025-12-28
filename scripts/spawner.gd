class_name Spawner
extends Node3D

var global_spawn_position: Vector3
var used: bool = false

func _ready() -> void:
	hide()
	global_spawn_position = self.calculate_spawn_position()

func calculate_spawn_position() -> Vector3:
	var cast_start_position_local: Vector3 = Vector3.ZERO
	var cast_range: float = 10.0
	var cast_collision_mask: int = 0b0001 # 0001 world, 0010 actor
	
	var space_state = self.get_world_3d().direct_space_state
	var raycast_start_position = self.to_global(Vector3.ZERO)
	var raycast_end_position = self.to_global(cast_start_position_local + Vector3.DOWN * cast_range)
	var query = PhysicsRayQueryParameters3D.create(raycast_start_position, raycast_end_position, cast_collision_mask)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	
	return result.position
