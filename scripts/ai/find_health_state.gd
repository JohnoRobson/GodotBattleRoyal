extends State

class_name FindHealthState

var current_target: HealthPickup

func enter(_controller: AiActorController):
	pass

func execute(controller: AiActorController):
	var closest_health = controller.world.get_closest_available_health(controller.actor.global_transform.origin)
	if closest_health != null:
		current_target = closest_health
	else:
		# there are no health pickups
		controller.state_machine.change_state(FindEnemyState.new())

func execute_physics(controller: AiActorController):
	if (current_target != null):
		var target_pos = current_target.global_transform.origin
		controller.actor.nav_agent.target_position = target_pos

		#move
		var current_location = controller.actor.global_transform.origin
		var next_location = controller.actor.nav_agent.get_next_path_position()
		var dir = (next_location - current_location).normalized()
		controller.set_move_direction(Vector2(dir.x, dir.z))
		controller.set_aim_position(controller.actor.to_global(Vector3(dir.x * 100, 0, dir.z * 100)))

		var target_distance: float = target_pos.distance_to(controller.actor.global_transform.origin)
		if target_distance <= 0.1:
			controller.state_machine.change_state(FindEnemyState.new())

func exit(controller: AiActorController):
	controller.set_move_direction(Vector2.ZERO)
	pass
