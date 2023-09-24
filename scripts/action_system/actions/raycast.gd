class_name ActionRaycast
extends Action

@export var cast_collision_mask: int = 0b0011
@export var cast_degrees_of_inaccuracy: Callable
@export var cast_start_position_local: Vector3 = Vector3.ZERO
@export var cast_range: float = 10.0
@export var targeted_actions: Array[TargetedAction] = []
@export var actions_to_apply_at_hit_location: Array[Action] = []

signal on_raycast(start_position_global: Vector3, end_position_global: Vector3)

func _init():
	action_name = self.Name.RAYCAST

func perform(_delta: float, item_node: ActionStack.ItemNode) -> bool:
	# need to figure this out. There needs to be a way to pass parameters at runtime to the action stack
	var aim_vector_local = Vector3.FORWARD
	var space_state = item_node.game_item.get_world_3d().direct_space_state
	var raycast_start_position = item_node.game_item.to_global(cast_start_position_local)
	var raycast_end_position = item_node.game_item.to_global(cast_start_position_local + aim_vector_local * cast_range)
	var query = PhysicsRayQueryParameters3D.create(raycast_start_position, raycast_end_position, cast_collision_mask)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	
	var raycast_end_position_after_check: Vector3
	# apply effect and damage
	if result:
		var raycast_hit_position = result.position
		on_raycast.emit(raycast_start_position, raycast_hit_position)
		var target = result.collider
		raycast_end_position_after_check = raycast_hit_position

		# this is kinda goofy and not generic
		if target != null and target.is_in_group("Hurtbox"):
			for targeted_action in targeted_actions:
				targeted_action.targets = [target.get_parent()]
			
			# do weird array type casting trick
			var action_array: Array[Action] = []
			action_array.assign(targeted_actions)
		
			# put the targeted actions at the front of the actions for the action system to perform so that they resolve before any child actions
			actions = action_array + actions
	else:
		on_raycast.emit(raycast_start_position, raycast_end_position)
		raycast_end_position_after_check = raycast_end_position
	
	if !actions_to_apply_at_hit_location.is_empty():
		# janky
		var fake_game_item: GameItem = preload("res://scenes/items/temp_gameitem.tscn").instantiate()
		item_node.data[Action.Keys.WORLD].return_item_to_world(fake_game_item, raycast_end_position_after_check, item_node.game_item.rotation)

		var action_system: ActionSystem = item_node.data[Action.Keys.ACTION_SYSTEM]
		fake_game_item.action_triggered.connect(action_system.action_triggered)

		for action in actions_to_apply_at_hit_location:
			var new_action = action.duplicate(true)
			item_node.child_nodes.append(ActionStack.ItemNode.new(new_action, fake_game_item, item_node))
		
			item_node.child_nodes.append(ActionStack.ItemNode.new(fake_game_item.action, fake_game_item, item_node))
	
	return true
