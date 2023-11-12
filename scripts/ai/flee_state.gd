class_name FleeState
extends State

var position_to_flee_to: Vector3

func enter(controller: AiActorController):
	# run in a straight line away from the closest explosive or actor
	var current_position  = controller.actor.global_position
	var distance_to_check_for_actors_and_items = 20.0

	var nearby_things: Array = controller.world.get_actors_and_gameitems_in_area(current_position, distance_to_check_for_actors_and_items).filter(func(a): return a != controller.actor)
	var nearby_actors: Array = nearby_things.filter(func(a): return a is Actor)
	var nearby_active_explosives: Array = nearby_things.filter(func(a): return a is GameItem).filter(func(a): return a.has_trait(GameItem.ItemTrait.EXPLOSIVE) and !a.can_be_used and !a.is_held)

	var average_danger_direction_local = Vector3()
	for actor in nearby_actors:
		var local_dir = (actor.global_position - current_position).normalized()
		average_danger_direction_local += local_dir

	for explosive in nearby_active_explosives:
		# the multiplier is to skew the direction of the danger in this direction, so that there's a better chance of the actor running away from this
		var local_dir = (explosive.global_position - current_position).normalized() * 2.0
		average_danger_direction_local += local_dir
	
	# flee in the opposite direction of the danger
	position_to_flee_to = (current_position - average_danger_direction_local).normalized() * 10.0 + current_position
	controller.nav_agent.target_position = position_to_flee_to
	
	pass

func execute(_controller: AiActorController):
	pass

func execute_physics(controller: AiActorController):
	#move
	var current_location = controller.actor.global_transform.origin
	var next_location = controller.nav_agent.get_next_path_position()
	var dir = (next_location - current_location).normalized()
	controller.set_move_direction(Vector2(dir.x, dir.z))
	controller.set_aim_position(controller.actor.to_global(Vector3(dir.x * 100, 0, dir.z * 100)))

	var target_distance: float = position_to_flee_to.distance_to(controller.actor.global_transform.origin)
	if target_distance <= 3.0:
		controller.state_machine.change_state(DecisionMakingState.new())

func exit(controller: AiActorController):
	controller.set_move_direction(Vector2.ZERO)
	pass

func get_name() -> String:
	return "FleeState"
