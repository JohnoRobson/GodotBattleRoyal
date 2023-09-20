class_name ActionRaycast
extends Action

@export var cast_collision_mask: int = 0b0011
@export var cast_degrees_of_inaccuracy: Callable
@export var cast_start_position_local: Vector3 = Vector3.ZERO
@export var cast_range: float = 10.0
@export var targeted_actions: Array[TargetedAction] = []

signal on_raycast(start_position_global: Vector3, end_position_global: Vector3)

func _init():
	action_name = self.Name.RAYCAST

func perform(_delta: float, game_item: GameItem) -> bool:
	# need to figure this out. There needs to be a way to pass parameters at runtime to the action stack
	# var aim_vector_local = VectorUtils.make_local_inaccuracy_vector(cast_degrees_of_inaccuracy.call())
	var aim_vector_local = Vector3.FORWARD
	var space_state = game_item.get_world_3d().direct_space_state
	var raycast_start_position = game_item.to_global(cast_start_position_local)
	var raycast_end_position = game_item.to_global(cast_start_position_local + aim_vector_local * cast_range)
	var query = PhysicsRayQueryParameters3D.create(raycast_start_position, raycast_end_position, cast_collision_mask)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result = space_state.intersect_ray(query)
	
	# apply effect and damage
	if result:
		var raycast_hit_position = result.position
		on_raycast.emit(raycast_start_position, raycast_hit_position)
		var target = result.collider

		# this is kinda goofy and not generic
		if target != null and target.is_in_group("Hurtbox"):
			for targeted_action in targeted_actions:
				targeted_action.targets = [target.get_parent()]
			
			# do weird array type casting trick
			var action_array: Array[Action] = []
			action_array.assign(targeted_actions)
		
			# put the targeted actions at the front of the actions for the action system to perform so that they resolve before any child actions
			actions = action_array + actions
			return true
	else:
		on_raycast.emit(raycast_start_position, raycast_end_position)
	
	return true
