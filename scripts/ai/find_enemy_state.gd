extends State

class_name FindEnemyState

var current_target: Actor

func enter(controller: AiActorController):
	current_target = controller.world.get_closest_actor(controller.actor.global_transform.origin, controller.actor)

func execute(controller: AiActorController):
	current_target = controller.world.get_closest_actor(controller.actor.global_transform.origin, controller.actor)

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
		if target_distance <= 10.0:
			controller.state_machine.change_state(ShootEnemyState.new())

func exit(controller: AiActorController):
	controller.set_move_direction(Vector2.ZERO)
	pass

func get_name() -> String:
	return "FindEnemyState"
