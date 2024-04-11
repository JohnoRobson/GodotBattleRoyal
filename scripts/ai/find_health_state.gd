extends State
class_name FindHealthState

func enter(_controller: AiActorController):
	pass

func execute(controller: AiActorController):
	var find_item_state = FindItemState.new()
	find_item_state.item_trait_to_find = GameItem.ItemTrait.HEALING
	controller.state_machine.change_state(find_item_state)

func execute_physics(_controller: AiActorController):
	pass

func exit(_controller: AiActorController):
	pass

func get_name() -> String:
	return "FindHealthState"

func evaluate(factor_context: FactorContext) -> float:
	var closest_health_item = factor_context.world.get_closest_available_health(factor_context.target_actor.global_transform.origin)
	var has_health_item = InventoryUtils.contains_trait(factor_context.target_actor.weapon_inventory.inventory_data, GameItem.ItemTrait.HEALING)
	if has_health_item or closest_health_item == null:
		return 0.0
	
	var health_factor: float = HealthFactor.evaluate(factor_context) / 2.0
	return clampf(health_factor + 0.6, 0.0, 1.0)
