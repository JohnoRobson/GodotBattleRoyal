class_name FindItemState
extends State

var item_trait_to_find: GameItem.ItemTrait

func _ready():
	assert(item_trait_to_find != null, "item_trait_to_find was not set!")

func enter(_controller: AiActorController):
	pass

func execute(controller: AiActorController):
	var closest_item_with_trait = controller.world.get_closest_item_with_trait(controller.actor.global_position, item_trait_to_find)
	
	if closest_item_with_trait != null and controller.actor.weapon_inventory.has_empty_slots():
		var pick_up_item_state = PickUpItemState.new()
		pick_up_item_state.current_target = closest_item_with_trait
		controller.state_machine.change_state(pick_up_item_state)
	else:
		# there are no free items
		controller.state_machine.change_state(DecisionMakingState.new())

func execute_physics(_controller: AiActorController):
	pass

func exit(_controller: AiActorController):
	pass

func get_name() -> String:
	return "FindItemState (%s)" % GameItem.ItemTrait.keys()[item_trait_to_find]
