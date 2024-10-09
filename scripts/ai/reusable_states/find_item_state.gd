class_name FindItemState
extends State

var _item_traits_to_find: Array[GameItem.ItemTrait]

func _init(item_traits_to_find: Array[GameItem.ItemTrait]):
	assert(item_traits_to_find != null, "item_trait_to_find was not set!")
	_item_traits_to_find = item_traits_to_find

func enter(_controller: AiActorController):
	pass

func execute(controller: AiActorController):
	var closest_item_with_trait = controller.world.get_closest_item_with_traits(controller.actor.global_position, _item_traits_to_find)
	
	if closest_item_with_trait != null and controller.actor.weapon_inventory.has_empty_slots():
		var pick_up_item_state = PickUpItemState.new(closest_item_with_trait)
		#pick_up_item_state.current_target = closest_item_with_trait
		controller.state_machine.change_state(pick_up_item_state)
	else:
		# there are no free items
		controller.state_machine.change_state(DecisionMakingState.new())

func execute_physics(_controller: AiActorController):
	pass

func exit(_controller: AiActorController):
	pass

func get_name() -> String:
	var item_traits_string = ""
	for item_trait: GameItem.ItemTrait in _item_traits_to_find:
		item_traits_string += GameItem.ItemTrait.keys()[item_trait] + ", "
		
	return "FindItemState (%s)" % item_traits_string
