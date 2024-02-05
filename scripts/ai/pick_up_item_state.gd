class_name PickUpItemState
extends State

var current_target: GameItem
var picked_up_weapon_last_tick: bool = false

func _ready():
	assert(current_target != null, "current target not set")

func enter(_controller: AiActorController):
	pass

func execute(controller: AiActorController):
	# make sure that the target can still be picked up
	if current_target.is_held:
		controller.state_machine.change_state(DecisionMakingState.new())

func execute_physics(controller: AiActorController):
	if (picked_up_weapon_last_tick):
		picked_up_weapon_last_tick = false
		controller.set_is_exchanging_weapon(false)
		controller.state_machine.change_state(DecisionMakingState.new())
	elif (current_target != null && !current_target.is_held):
		var target_pos = current_target.global_transform.origin
		controller.nav_agent.target_position = target_pos

		#move
		var current_location = controller.actor.global_transform.origin
		var next_location = controller.nav_agent.get_next_path_position()
		var dir = (next_location - current_location).normalized()
		controller.set_move_direction(Vector2(dir.x, dir.z))
		controller.set_aim_position(current_target.global_position)

		var closest_item = controller.actor._item_pickup_manager.get_item_that_cursor_is_over_and_is_in_interaction_range()
		if closest_item == current_target:
			if !InventoryUtils.switch_to_empty_slot(controller.actor.weapon_inventory):
				controller.state_machine.change_state(DecisionMakingState.new()) # just a safty check
			controller.set_is_exchanging_weapon(true)
			picked_up_weapon_last_tick = true

func exit(controller: AiActorController):
	controller.set_is_exchanging_weapon(false)
	controller.set_move_direction(Vector2.ZERO)

func get_name() -> String:
	return "PickUpItemState"
