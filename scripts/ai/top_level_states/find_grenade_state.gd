class_name FindGrenadeState
extends State

func enter(_controller: AiActorController) -> void:
	pass

func execute(controller: AiActorController) -> void:
	var find_item_state := FindItemState.new([GameItem.ItemTrait.EXPLOSIVE, GameItem.ItemTrait.THROWABLE])
	controller.state_machine.change_state(find_item_state)

func execute_physics(_controller: AiActorController) -> void:
	pass

func exit(_controller: AiActorController) -> void:
	pass

func get_name() -> String:
	return "FindGrenadeState"

func evaluate(factor_context: FactorContext) -> float:
	var has_grenade = InventoryUtils\
	.contains_traits(factor_context.target_actor.inventory.inventory_data, [GameItem.ItemTrait.THROWABLE, GameItem.ItemTrait.EXPLOSIVE])
	var closest_grenade = factor_context.world.get_closest_item_with_traits(factor_context.target_actor.global_transform.origin, [GameItem.ItemTrait.THROWABLE, GameItem.ItemTrait.EXPLOSIVE])
	if has_grenade or closest_grenade == null:
		return 0.0
	elif closest_grenade.global_position.distance_to(factor_context.target_actor.global_position) < 80:
		return clampf(Factors.evaluate_equipment_factor(factor_context) - Factors.evaluate_danger_factor(factor_context) / 4.0, 0.0, 1.0)
	else:
		return 0.0
