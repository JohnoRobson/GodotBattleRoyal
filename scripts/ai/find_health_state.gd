extends State

class_name FindHealthState

var current_target: GameItem
var medkit_pickup_countdown: int = -1
var medkit_pickup_routine_started: bool = false

func enter(_controller: AiActorController):
	pass

func execute(controller: AiActorController):
	var closest_health = controller.world.get_closest_available_health(controller.actor.global_transform.origin)
	if medkit_pickup_routine_started:	
		# do nothing, you are holding a medkit
		return
	if closest_health != null:
		current_target = closest_health
		if controller.actor.health.is_max_health():
			# no reason to get health pickups if you're at max health
			controller.state_machine.change_state(FindEnemyState.new())
	else:
		# there are no health pickups
		controller.state_machine.change_state(FindEnemyState.new())

func execute_physics(controller: AiActorController):
	if medkit_pickup_routine_started and medkit_pickup_countdown > 0:
		medkit_pickup_countdown -= 1
		# health has been picked up
		controller.set_is_shooting(true)
	elif medkit_pickup_routine_started and medkit_pickup_countdown <= 0:
		# medkit has been used
		controller.set_is_shooting(false)
		controller.state_machine.change_state(FindEnemyState.new())
	else:
		# find medkit
		controller.set_is_exchanging_weapon(false)

		if (current_target != null):
			var target_pos = current_target.global_transform.origin
			controller.nav_agent.target_position = target_pos

			#move
			var current_location = controller.actor.global_transform.origin
			var next_location = controller.nav_agent.get_next_path_position()
			var dir = (next_location - current_location).normalized()
			controller.set_move_direction(Vector2(dir.x, dir.z))
			controller.set_aim_position(target_pos)

			var target_distance: float = target_pos.distance_to(controller.actor.global_transform.origin)

			if target_distance <= 5 and controller.actor.held_weapon != null:
				#drop weapon
				controller.set_is_exchanging_weapon(true)
			
			if target_distance <= 2	 and controller.actor.held_weapon == null:
				# pick up medkit
				controller.set_is_exchanging_weapon(true)
				medkit_pickup_countdown = 1
				medkit_pickup_routine_started = true

func exit(controller: AiActorController):
	controller.set_move_direction(Vector2.ZERO)
	controller.set_is_exchanging_weapon(false)
	controller.set_is_shooting(false)
	pass

func get_name() -> String:
	return "FindHealthState"