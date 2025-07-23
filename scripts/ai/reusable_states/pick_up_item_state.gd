class_name PickUpItemState extends State

var _current_target: GameItem
var picked_up_weapon_last_tick: bool = false
var current_controller: AiActorController
var nav_agent: NavigationAgent3D

func _init(current_target: GameItem):
	assert(current_target != null, "current target not set")
	_current_target = current_target

func enter(controller: AiActorController):
	current_controller = controller
	nav_agent = controller.nav_agent
	current_controller.nav_agent.velocity_computed.connect(_on_velocity_computed)

func execute(controller: AiActorController):
	# make sure that the target can still be picked up
	if _current_target.is_held:
		controller.state_machine.change_state(DecisionMakingState.new())

func execute_physics(controller: AiActorController):
	if picked_up_weapon_last_tick && _current_target.is_held:
		picked_up_weapon_last_tick = false
		controller.set_is_exchanging_weapon(false)
		controller.state_machine.change_state(DecisionMakingState.new())
	elif _current_target != null && !_current_target.is_held:
		var target_pos = _current_target.global_transform.origin
		nav_agent.target_position = target_pos

		#move
		var current_location = controller.actor.global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		var dir = (next_location - current_location).normalized()
		if nav_agent.avoidance_enabled:
			nav_agent.velocity = dir * controller.actor.speed
		else:
			controller.set_move_direction(Vector2(dir.x, dir.z))
		controller.set_aim_position(_current_target.global_position)

		var closest_item = controller.actor._item_pickup_manager.get_item_that_cursor_is_over_and_is_in_interaction_range()
		if closest_item == _current_target:
			if !InventoryUtils.switch_to_empty_slot(controller.actor.inventory):
				controller.state_machine.change_state(DecisionMakingState.new()) # just a safety check
			controller.set_is_exchanging_weapon(true)
			picked_up_weapon_last_tick = true

func exit(controller: AiActorController):
	controller.set_is_exchanging_weapon(false)
	controller.set_move_direction(Vector2.ZERO)
	controller.nav_agent.velocity_computed.disconnect(_on_velocity_computed)

func get_name() -> String:
	return "PickUpItemState"

# used for nav agent collision avoidance
func _on_velocity_computed(safe_velocity: Vector3):
	var dir = safe_velocity.normalized()
	current_controller.set_move_direction(Vector2(dir.x, dir.z))

func can_be_interrupted_by(state: State) -> bool:
	if state is FindWeaponState and _current_target is Weapon:
		return false
	elif state is FindGrenadeState and _current_target.has_trait(GameItem.ItemTrait.EXPLOSIVE):
		return false
	elif state is FindHealthState and _current_target.has_trait(GameItem.ItemTrait.HEALING):
		return false
	return true
