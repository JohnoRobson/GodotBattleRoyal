extends State
class_name FindWeaponState

func enter(_controller: AiActorController):
	pass

func execute(controller: AiActorController):
	var find_item_state = FindItemState.new()
	find_item_state.item_trait_to_find = GameItem.ItemTrait.FIREARM
	controller.state_machine.change_state(find_item_state)

func execute_physics(_controller: AiActorController):
	pass

func exit(_controller: AiActorController):
	pass

func get_name() -> String:
	return "FindWeaponState"

func evaluate(factor_context: FactorContext) -> float:
	var has_weapon = InventoryUtils.contains_trait(factor_context.target_actor.weapon_inventory.inventory_data, GameItem.ItemTrait.FIREARM)
	return 0.0 if has_weapon else 1.0
