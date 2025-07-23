class_name FightState extends State
## This state has a few goals:
## 1.  if the movement_override_target is set, then the state will make the actor
##     move towards it, ignoring other behaviour and set the movement_state to MOVING_TOWARDS_MOVEMENT_OVERRIDE
## 2.  switch to the best weapon for the current range that has ammo, either in the magazine or in the inventory
## 3.  reload the weapon if it is out of ammo
## 4.  if the movement_override_target is not set, set the movement_state to MOVING_TOWARDS_ACTOR
## 5.  if the movement_state is MOVING_TOWARDS_MOVEMENT_OVERRIDE, then move the actor towards it,
##     otherwise attempt to maintain the optimal range for the current weapon
## 6.  attack the current_target when there is a clear line of sight to the target (wip) and when the weapon is aimed at the target	

const RANGE_THRESHOLD: float = 3.0
const TICKS_BETWEEN_TARGET_CHANGE_CHECK: int = 60
const MAX_WEAPON_RANGE_TO_CONSIDER: float = 50.0 # effective sniper range is like 200, you can't see further than like 50
const MIN_WEAPON_SCORE_TO_FIRE: float = 0.2
const MIN_DEGREES_TO_FIRE_GUN: float = 45
const MIN_DEGREES_TO_THROW_GRENADE: float = 20
const AIM_OFFSET_TO_HIT_MIDDLE_OF_ACTOR: Vector3 = Vector3(0, 1.5, 0)

var tick_count_for_target_check: int = 0

var current_target: Actor
var movement_override_target: Vector3
var current_movement_target: Vector3
var movement_state: Movement
var current_controller: AiActorController
var nav_agent: NavigationAgent3D

enum Movement {
	MOVING_TOWARDS_ACTOR,
	MOVING_TOWARDS_MOVEMENT_OVERRIDE
}

enum DirectionToMove {
	TOWARDS_TARGET,
	AWAY_FROM_TARGET,
	STAY_STILL
}

func enter(controller: AiActorController):
	current_controller = controller
	nav_agent = controller.nav_agent
	acquire_and_set_target()
	
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	
	# if movement is MOVING_TOWARDS_MOVEMENT_OVERRIDE, then the current_movement_target must be set
	# otherwise throw
	if movement_state == null:
		movement_state = Movement.MOVING_TOWARDS_ACTOR
	
	if movement_state == Movement.MOVING_TOWARDS_MOVEMENT_OVERRIDE:
		assert(movement_override_target != null)
	
	if current_target == null:
		# can't switch back to decision making state, because that would cause a stack overflow
		return
	
	# safety check to make sure the Actor has a weapon
	if !_has_weapon(controller.actor):
		controller.state_machine.change_state(DecisionMakingState.new())
		return
	else:
		_equip_best_weapon_for_current_circumstance(controller)

func execute(controller: AiActorController):
	# find target
	tick_count_for_target_check += 1
	if tick_count_for_target_check >= TICKS_BETWEEN_TARGET_CHANGE_CHECK:
		tick_count_for_target_check = 0
		acquire_and_set_target()
		_equip_best_weapon_for_current_circumstance(controller)
	
	# aiming and shooting
	if current_target == null:
		controller.state_machine.change_state(DecisionMakingState.new())
		return
	else:
		var target_pos = current_target.global_position
		
		controller.set_aim_position(target_pos + AIM_OFFSET_TO_HIT_MIDDLE_OF_ACTOR)
		
		var weapon = controller.actor.held_weapon
		
		if weapon != null && weapon is Weapon && weapon.empty_and_can_reload():
			controller.set_is_reloading(true)
		else:
			controller.set_is_reloading(false)
		var held_item = controller.actor.held_weapon
		if held_item != null:
			var item_is_grenade = [GameItem.ItemTrait.EXPLOSIVE, GameItem.ItemTrait.THROWABLE].all(func(a): return held_item.traits.has(a))
			var weapon_score = _score_weapon_in_current_context(weapon, controller.actor)
			var score_is_high_enough = weapon_score >= MIN_WEAPON_SCORE_TO_FIRE
			if score_is_high_enough:
				if item_is_grenade:
					controller.set_is_shooting(_is_pointing_at_target(weapon, target_pos, MIN_DEGREES_TO_THROW_GRENADE))
				else:
					controller.set_is_shooting(_is_pointing_at_target(weapon, target_pos, MIN_DEGREES_TO_FIRE_GUN))
			else:
				controller.set_is_shooting(false)

func execute_physics(controller: AiActorController):
	if !is_instance_valid(current_target) or current_target == null or !is_instance_valid(nav_agent):
		controller.state_machine.change_state(DecisionMakingState.new())
		return
	
	# movement
	var movement_target: Vector3
	var current_global_position: Vector3 = controller.actor.global_position
	var current_target_position: Vector3 = current_target.global_position
	
	match movement_state:
		Movement.MOVING_TOWARDS_ACTOR:
			var direction_to_move: DirectionToMove = _determine_direction_to_move(controller.actor)
			
			match direction_to_move:
				DirectionToMove.TOWARDS_TARGET:
					movement_target = current_target_position
				DirectionToMove.AWAY_FROM_TARGET:
					var away_dir := -(current_target_position - current_global_position).normalized()
					movement_target = current_global_position + away_dir * 2.0
				DirectionToMove.STAY_STILL:
					movement_target = controller.actor.global_position
		Movement.MOVING_TOWARDS_MOVEMENT_OVERRIDE:
			movement_target = movement_override_target
	
	nav_agent.target_position = movement_target
	var current_location = controller.actor.global_position
	var next_location = controller.nav_agent.get_next_path_position()
	var dir_to_move = (next_location - current_location).normalized()
	if nav_agent.avoidance_enabled:
			nav_agent.velocity = dir_to_move * controller.actor.speed
	else:
		controller.set_move_direction(Vector2(dir_to_move.x, dir_to_move.z))

func exit(controller: AiActorController):
	controller.set_move_direction(Vector2.ZERO)
	controller.set_is_shooting(false)
	controller.set_is_reloading(false)
	controller.nav_agent.velocity_computed.disconnect(_on_velocity_computed)

func get_name() -> String:
	return "FightState"

func _has_weapon(actor: Actor) -> bool:
	return InventoryUtils.contains_traits(actor.inventory.inventory_data, [GameItem.ItemTrait.FIREARM]) \
	|| InventoryUtils.contains_traits(actor.inventory.inventory_data, [GameItem.ItemTrait.THROWABLE, GameItem.ItemTrait.EXPLOSIVE])

func _equip_best_weapon_for_current_circumstance(controller: AiActorController) -> void:
	var items: Array[GameItem] = InventoryUtils.get_all_items_in_inventory(controller.actor.inventory)
	var best_item: GameItem = null
	var best_item_score: float = -1.0
	for item: GameItem in items:
		var score = _score_weapon_in_current_context(item, controller.actor)
		if score > best_item_score:
			best_item_score = score
			best_item = item
	
	if best_item != null:
		InventoryUtils.switch_to_item(controller.actor.inventory, best_item)

func _is_pointing_at_target(weapon: GameItem, target_pos_global: Vector3, degrees: float) -> bool:
	var weapon_direction_local: Vector3 = (weapon.to_global(Vector3.FORWARD) - weapon.global_position).normalized()
	var target_position_adjusted = target_pos_global + AIM_OFFSET_TO_HIT_MIDDLE_OF_ACTOR
	var target_pos_local: Vector3 = (target_position_adjusted - weapon.global_position).normalized()
	var angle = rad_to_deg(acos(weapon_direction_local.dot(target_pos_local)))
	return angle <= degrees

## Returns a value between 0.0 and 1.0 inclusive that rates 
## how good the weapon is in the current context
func _score_weapon_in_current_context(game_item: GameItem, this_actor: Actor) -> float:
	if game_item == null or this_actor == null:
		return 0.0
	var item_is_weapon = game_item is Weapon
	var item_is_grenade = [GameItem.ItemTrait.EXPLOSIVE, GameItem.ItemTrait.THROWABLE].all(func(a): return game_item.traits.has(a))
	if !item_is_weapon and !item_is_grenade:
		return 0.0
	
	# adjust weapon score for ammo
	if item_is_weapon:
		var weapon_ammo_category = (game_item as Weapon).stats.ammo_category
		var weapon_has_ammo_in_magazine: bool = (game_item as Weapon)._ammo != null and (game_item as Weapon)._ammo.current_ammo_in_magazine > 0
		var ammo_for_weapon_in_inventory: Array[GameItem] = InventoryUtils.get_all_ammo_of_category(this_actor.inventory, weapon_ammo_category)
		if !weapon_has_ammo_in_magazine and ammo_for_weapon_in_inventory.size() == 0:
			return 0.0
	
	var target_distance: float = current_target.global_position.distance_to(this_actor.global_position)
	# clamp target_distance between 0 and 100 so that we have a known range to work with
	target_distance = clampf(target_distance, 0.0, 100.0)
	
	var desired_distance: float = clampf(ItemEvaluator.get_item_range(game_item, false), 0, MAX_WEAPON_RANGE_TO_CONSIDER)
	
	var clamped_score = clampf(1 - abs(desired_distance - target_distance) * 0.025, 0.0, 1.0)
	
	# hack so that the actor can always fire their gun if they've decided to not move
	if clamped_score < MIN_WEAPON_SCORE_TO_FIRE and _determine_direction_to_move(this_actor) == DirectionToMove.STAY_STILL:
		return clampf(clamped_score + MIN_WEAPON_SCORE_TO_FIRE, 0.0, 1.0)
	
	return clamped_score

func _determine_direction_to_move(this_actor: Actor) -> DirectionToMove:
	var current_weapon: GameItem = this_actor.held_weapon
	
	if current_weapon == null:
		return DirectionToMove.AWAY_FROM_TARGET
	
	#var item_range_when_moving: float = clampf(ItemEvaluator.get_item_range(current_weapon, true), 0, MAX_WEAPON_RANGE_TO_CONSIDER)
	var item_range_when_stationary: float = clampf(ItemEvaluator.get_item_range(current_weapon, false), 0, MAX_WEAPON_RANGE_TO_CONSIDER)
	var target_distance: float = current_target.global_position.distance_to(this_actor.global_position)
	
	# range is too high for how close the camera is. divide it for now
	item_range_when_stationary = item_range_when_stationary / 3.0
	
	# how to determine if you should close, fall back or stay still?
	# special case for very accurate weapons
	if is_equal_approx(item_range_when_stationary, 50.0) and target_distance >= 15:
		return DirectionToMove.STAY_STILL
	
	# am I at a good range right now if I don't move? (stationary range)
	if target_distance + RANGE_THRESHOLD >= item_range_when_stationary and item_range_when_stationary >= target_distance - RANGE_THRESHOLD:
		return DirectionToMove.STAY_STILL
	elif target_distance - RANGE_THRESHOLD < item_range_when_stationary:
		# should I move away? (stationary range)
		return DirectionToMove.AWAY_FROM_TARGET
	else:
		# should I close? (moving range)
		return DirectionToMove.TOWARDS_TARGET

# used for nav agent collision avoidance
func _on_velocity_computed(safe_velocity: Vector3):
	var dir = safe_velocity.normalized()
	if is_instance_valid(current_controller):
		current_controller.set_move_direction(Vector2(dir.x, dir.z))

func evaluate(factor_context: FactorContext) -> float:
	var has_weapon: bool = _has_weapon(factor_context.target_actor)
	if !has_weapon:
		return 0.0
	
	return clampf(0.3 - Factors.evaluate_danger_factor(factor_context) / 3.0, 0.0, 1.0)

func acquire_and_set_target() -> void:
	var self_actor = current_controller.actor

	var team_members:Array[Actor] = [self_actor]
	if (self_actor.team != null):
		team_members = self_actor.team.get_members()

	var new_target = current_controller.world.get_closest_actor(self_actor.global_position, team_members)
	# print("current actor: %s new target: %s" % [self_actor, new_target])
	assert(new_target != self_actor)
	assert(!is_same(new_target, self_actor))
	current_target = new_target
