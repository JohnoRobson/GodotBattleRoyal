class_name DecisionMaker

# things that can be done in the game:
# 1.  moving
# 2.  picking up items
# 3.  using items
#
# actions that actors can do in the game:
# 1.  running away
# 2.  looting
# 3.  healing
# 4.  attacking
#
# rough priority of actions:
# 1.  looting
# 2.  attacking
# 3.  running away
# 4.  healing
static func get_state_to_do(controller: AiActorController):
	var factor_context: FactorContext = FactorContext.new(controller.world, controller.actor, controller.actor.global_position)
	# 1. should we loot?
	var loot_factor: float = LootFactor.evaluate(factor_context)
	var equipment_factor: float = EquipmentFactor.evaluate(factor_context)
	# 2. should we attack?
	# 3. should we run away?
	var danger_factor: float = DangerFactor.evaluate(factor_context)
	# 4. should we heal?
	var health_factor: float = HealthFactor.evaluate(factor_context)
	
	if (health_factor > 0.6 and (controller.world.get_closest_item_with_trait(controller.actor.global_transform.origin, GameItem.ItemTrait.HEALING) != null or InventoryUtils.contains_trait(controller.actor.weapon_inventory.inventory_data, GameItem.ItemTrait.HEALING))):
		return FindHealthState.new()

	if equipment_factor > 0.5:
		# determine what items are needed
		var has_weapon = InventoryUtils.contains_trait(factor_context.target_actor.weapon_inventory.inventory_data, GameItem.ItemTrait.FIREARM)
		var find_item_state = FindItemState.new()
		if !has_weapon:
			find_item_state.item_trait_to_find = GameItem.ItemTrait.FIREARM
			return find_item_state
		elif controller.world.get_closest_available_health(controller.actor.global_transform.origin) != null:
			find_item_state.item_trait_to_find = GameItem.ItemTrait.HEALING
			return find_item_state
	
	if danger_factor >= 1.0 or (danger_factor > 0.4 and health_factor > 0.3):
		return FleeState.new()
	
	return FindEnemyState.new()
