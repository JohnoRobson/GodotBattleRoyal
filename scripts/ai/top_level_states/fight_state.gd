class_name FightState extends State
## This state has a few goals:
## 1.  move towards the current_movement_target
## 2.  equip the best weapon for the current situation, currently, this would
##     only take distance from the current_target into account
## 3.  attack the current_target when there is a clear line of sight to the target
var current_target: Actor
var current_movement_target: Vector3
var movement: Movement

enum Movement {
	MOVING_TOWARDS_ACTOR,
	MOVING_TOWARDS_MOVEMENT_TARGET
}

func enter(controller: AiActorController):
	# safety check to make sure the Actor has a weapon
	if !_has_weapon(controller.actor):
		controller.state_machine.change_state(DecisionMakingState.new())
		return
	else:
		_equip_best_weapon(controller)
	
	# if movement is MOVING_TOWARDS_MOVEMENT_TARGET, then the current_movement_target must be set
	# otherwise throw
	if movement == null:
		movement = Movement.MOVING_TOWARDS_ACTOR
	
	if movement == Movement.MOVING_TOWARDS_MOVEMENT_TARGET:
		assert(current_movement_target != null)
	
	current_target = controller.world.get_closest_actor(controller.actor.global_position, controller.actor)

func execute(controller: AiActorController):
	current_target = controller.world.get_closest_actor(controller.actor.global_position, controller.actor)
	
	# aiming and shooting
	if current_target == null:
		controller.state_machine.change_state(DecisionMakingState.new())
	else:
		var target_pos = current_target.global_position
		controller.set_aim_position(target_pos + (Vector3.UP * 1.5))
		
		var weapon = controller.actor.held_weapon

		if weapon != null && weapon is Weapon && weapon.empty_and_can_reload():
			controller.set_is_reloading(true)
		else:
			controller.set_is_reloading(false)
			
		var is_in_range_and_pointing_at_target = (_score_weapon_in_current_context(weapon, controller.actor) >= 0.3
			&& is_pointing_at_target(weapon, target_pos))
		
		controller.set_is_shooting(is_in_range_and_pointing_at_target)

func execute_physics(controller: AiActorController):
	if current_target == null:
		controller.state_machine.change_state(DecisionMakingState.new())
	# movement
	var movement_target: Vector3
	match movement:
		Movement.MOVING_TOWARDS_ACTOR:
			movement_target = current_target.global_position
		Movement.MOVING_TOWARDS_MOVEMENT_TARGET:
			movement_target = current_movement_target
	
	controller.nav_agent.target_position = movement_target
	var current_location = controller.actor.global_position
	var next_location = controller.nav_agent.get_next_path_position()
	var dir = (next_location - current_location).normalized()
	
	var weapon = controller.actor.held_weapon
	
	match movement:
		Movement.MOVING_TOWARDS_ACTOR:
			var movement_score = _score_weapon_in_current_context(weapon, controller.actor)
			#print(movement_score)
			if movement_score <= 0.5:
				controller.set_move_direction(Vector2(dir.x, dir.z))
			else:
				controller.set_move_direction(Vector2()) # arrived at destination
			movement_target = current_target.global_position
		Movement.MOVING_TOWARDS_MOVEMENT_TARGET:
			movement_target = current_movement_target
			controller.set_move_direction(Vector2(dir.x, dir.z))

func exit(controller: AiActorController):
	controller.set_move_direction(Vector2.ZERO)

func get_name() -> String:
	return "FightState"

func _has_weapon(actor: Actor) -> bool:
	return InventoryUtils.contains_trait(actor.weapon_inventory.inventory_data, GameItem.ItemTrait.FIREARM)

func _equip_best_weapon(controller: AiActorController) -> void:
	InventoryUtils.switch_to_item_with_trait(controller.actor.weapon_inventory, GameItem.ItemTrait.FIREARM)

func is_pointing_at_target(weapon: GameItem, target_pos_global: Vector3) -> bool:
	var weapon_direction_local: Vector3 = weapon.to_global(Vector3.FORWARD)
	var target_pos_local: Vector3 = target_pos_global - weapon.global_position
	var dot_product = acos(weapon_direction_local.dot(target_pos_local))
	return dot_product <= 10.0

## Returns a value between 0.0 and 1.0 inclusive that rates 
## how good the weapon is in the current context
func _score_weapon_in_current_context(_weapon: Weapon, this_actor: Actor) -> float:
	var target_distance: float = current_target.global_position.distance_to(this_actor.global_position)
	# clamp target_distance between 0 and 100 so that we have a known range to work with
	target_distance = clampf(target_distance, 0.0, 100.0)
	
	var desired_distance: float = 20 # to be improved
	
	return clampf(1 - abs(desired_distance - target_distance) * 0.025, 0.0, 1.0)

func evaluate(factor_context: FactorContext) -> float:
	var has_weapon: bool = _has_weapon(factor_context.target_actor)
	if !has_weapon:
		return 0.0
	
	return clampf(0.5 + DangerFactor.evaluate(factor_context) / 2.0, 0.0, 1.0)
