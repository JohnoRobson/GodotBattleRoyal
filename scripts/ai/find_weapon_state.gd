extends State

class_name FindWeaponState

var current_target: Weapon

func enter(_controller: AiActorController):
	pass

func execute(controller: AiActorController):
	var closest_weapon = controller.world.get_closest_available_weapon(controller.actor.global_transform.origin)
	if closest_weapon != null:
		current_target = closest_weapon
	else:
		# there are no free weapons
		controller.state_machine.change_state(FindEnemyState.new())

func execute_physics(controller: AiActorController):
	if (current_target != null):
		var target_pos = current_target.global_transform.origin
		controller.nav_agent.target_position = target_pos

		#move
		var current_location = controller.actor.global_transform.origin
		var next_location = controller.nav_agent.get_next_path_position()
		var dir = (next_location - current_location).normalized()
		controller.set_move_direction(Vector2(dir.x, dir.z))
		controller.set_aim_position(controller.actor.to_global(Vector3(dir.x * 100, 0, dir.z * 100)))

		var target_distance: float = target_pos.distance_to(controller.actor.global_transform.origin)
		if target_distance <= 0.1 || controller.actor.held_weapon != null:
			# weapon has been picked up
			controller.state_machine.change_state(FindEnemyState.new())

func exit(controller: AiActorController):
	controller.set_move_direction(Vector2.ZERO)
	pass
