class_name ItemEvaluator

## returns the max range of the GameItem, or -1 if it has no range
## (either the first raycast or the first throw range action in a GameItem)
static func get_item_range(game_item: GameItem, when_moving: bool) -> float:
	var first_action: Action = game_item.action
	
	if game_item is Weapon:
		# assume it being a weapon means it is a gun for now
		# get the raycast action
		var raycast_action: ActionRaycast = raycast_search(first_action, 1, 3)
		
		if raycast_action == null:
			return -1
		
		# get the raycast range
		var raycast_range: float = raycast_action.cast_range
		
		# calculate a reasonable range, taking inaccuracy into account 
		var inaccuracy_degrees: float
		if when_moving:
			inaccuracy_degrees = (game_item as Weapon).stats.degrees_of_inaccuracy_moving
		else:
			inaccuracy_degrees = (game_item as Weapon).stats.degrees_of_inaccuracy_stationary
		var max_allowable_inaccuracy_from_aimpoint: float = 4.0 # the opposite side of a right triangle
		# sin(angle) = opposite / hypotenuse, therefor hypotenuse = opposite / sin(angle)
		var calculated_max_range_including_inaccuracy: float = max_allowable_inaccuracy_from_aimpoint / sin(deg_to_rad(inaccuracy_degrees))
		
		# return the lesser range
		var effective_range: float = calculated_max_range_including_inaccuracy if raycast_range > calculated_max_range_including_inaccuracy else raycast_range
		#print("item : %s, range, : %s" % [ game_item.item_name, range ])
		return effective_range
	
	# assume a ballistic trajectory on flat ground
	if game_item.action is ActionThrow:
		var velocity: float = (game_item.action as ActionThrow).force
		const angle: float = sin(PI/4)
		var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
		var throwing_range: float = ((velocity * angle + sqrt(pow(velocity * angle, 2))) / gravity) * cos(PI/4) * velocity
		return throwing_range
	
	return -1

static func raycast_search(action: Action, current_depth: int, max_depth: int) -> ActionRaycast:
	#print("action: %s, current_depth: %s, max_depth: %s" % [Action.Name.keys()[action.action_name], current_depth, max_depth])
	
	if action is ActionRaycast:
		return action as ActionRaycast
	
	if current_depth >= max_depth:
		return null
	
	var actions_to_call: Array[Action] = []
	actions_to_call.append_array(action.actions)
	
	if action is ActionRepeat:
		actions_to_call.append((action as ActionRepeat).action_to_repeat)
		
	if action is ActionRepeatDelay:
		actions_to_call.append((action as ActionRepeatDelay).action_to_repeat)
	
	for a: Action in actions_to_call:
		var result = raycast_search(a, current_depth + 1, max_depth)
		if result is ActionRaycast:
			return result
	
	return null
	
