extends State
class_name FindWeaponState

func enter(_controller: AiActorController):
	pass

func execute(controller: AiActorController):
	var find_item_state := FindItemState.new()
	find_item_state.item_traits_to_find = [ GameItem.ItemTrait.FIREARM ]
	controller.state_machine.change_state(find_item_state)

func execute_physics(_controller: AiActorController):
	pass

func exit(_controller: AiActorController):
	pass

func get_name() -> String:
	return "FindWeaponState"

func evaluate(factor_context: FactorContext) -> float:
	var has_weapon = InventoryUtils.contains_trait(factor_context.target_actor.weapon_inventory.inventory_data, [GameItem.ItemTrait.FIREARM])
	var weapons_exist_that_can_be_picked_up = factor_context.world.get_closest_available_weapon(factor_context.target_actor.global_position)
	return 0.0 if has_weapon or !weapons_exist_that_can_be_picked_up else 0.8
