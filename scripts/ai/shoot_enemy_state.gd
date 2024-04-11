extends State

class_name ShootEnemyState

var current_target: Actor

func enter(controller: AiActorController):
	current_target = controller.world.get_closest_actor(controller.actor.global_transform.origin, controller.actor)

func execute(controller: AiActorController):
	if current_target == null:
		controller.state_machine.change_state(DecisionMakingState.new())
	else:
		var target_pos = current_target.global_transform.origin
		var target_distance: float = target_pos.distance_to(controller.actor.global_transform.origin)

		var weapon = controller.actor.held_weapon
		if weapon != null && weapon is Weapon && weapon.empty_and_can_reload():
			controller.set_is_reloading(true)
		else:
			controller.set_is_reloading(false)

		if target_distance <= 10.0 && weapon != null && is_pointing_at_target(weapon, target_pos):
			controller.set_aim_position(target_pos + (Vector3.UP * 1.5))
			controller.set_is_shooting(true)
		else:
			controller.state_machine.change_state(DecisionMakingState.new())

func execute_physics(_controller: AiActorController):
	pass

func exit(controller: AiActorController):
	controller.set_is_shooting(false)

func get_name() -> String:
	return "ShootEnemyState"

func is_pointing_at_target(weapon: GameItem, target_pos_global: Vector3) -> bool:
	var weapon_direction_local: Vector3 = weapon.to_global(Vector3.FORWARD)
	var target_pos_local: Vector3 = target_pos_global - weapon.global_position
	var dot_product = acos(weapon_direction_local.dot(target_pos_local))
	return dot_product <= 10.0
