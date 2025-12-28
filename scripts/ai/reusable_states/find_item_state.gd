class_name FindItemState
extends State

var _item_traits_to_find: Array[GameItem.ItemTrait]
var _ammo_types_to_find: Array[AmmoType.AmmoCategory]
var _search_type: SearchType

enum SearchType {
	SEARCHING_FOR_ITEM,
	SEARCHING_FOR_AMMO
}

func _init(item_traits_to_find: Array[GameItem.ItemTrait] = [], ammo_types_to_find: Array[AmmoType.AmmoCategory] = []):
	assert(item_traits_to_find != null or item_traits_to_find != null, "item_trait_to_find or item_traits_to_find was not set!")
	assert(!(!item_traits_to_find.is_empty() and !ammo_types_to_find.is_empty()), "Cannot search for both items and ammo")
	
	if !item_traits_to_find.is_empty():
		_search_type = SearchType.SEARCHING_FOR_ITEM
	else:
		_search_type = SearchType.SEARCHING_FOR_AMMO
	
	_item_traits_to_find = item_traits_to_find
	_ammo_types_to_find = ammo_types_to_find

func enter(_controller: AiActorController):
	pass

func execute(controller: AiActorController):
	if _search_type == SearchType.SEARCHING_FOR_ITEM:
		var closest_item_with_trait = controller.world.get_closest_item_with_traits(controller.actor.global_position, _item_traits_to_find)
		
		if closest_item_with_trait != null and controller.actor.inventory.has_empty_slots():
			var pick_up_item_state = PickUpItemState.new(closest_item_with_trait)
			controller.state_machine.change_state(pick_up_item_state)
		else:
			# there are no free items
			controller.state_machine.change_state(DecisionMakingState.new())
	else:
		var closest_ammo: Ammo = controller.world.get_closest_ammo_of_category(controller.actor.global_transform.origin, _ammo_types_to_find[0])
		
		if closest_ammo != null and controller.actor.inventory.has_empty_slots():
			var pick_up_item_state = PickUpItemState.new(closest_ammo)
			controller.state_machine.change_state(pick_up_item_state)
		else:
			# there are no free items
			controller.state_machine.change_state(DecisionMakingState.new())
		return


func execute_physics(_controller: AiActorController):
	pass

func exit(_controller: AiActorController):
	pass

func get_name() -> String:
	var traits_string = ""
	
	if _search_type == SearchType.SEARCHING_FOR_ITEM:
		for item_trait: GameItem.ItemTrait in _item_traits_to_find:
			traits_string += GameItem.ItemTrait.keys()[item_trait] + " Item, "
	else:
		for ammo_category: AmmoType.AmmoCategory in _ammo_types_to_find:
			traits_string += AmmoType.AmmoCategory.keys()[ammo_category] + " Ammo, "
		
	return "FindItemState (%s)" % traits_string
