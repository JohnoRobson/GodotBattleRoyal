class_name EquipmentFactor
extends Factor

static func evaluate(factor_context: FactorContext) -> float:
	var number_of_items_in_inventory = factor_context.target_actor.weapon_inventory.number_of_filled_slots()
	var size_of_inventory = factor_context.target_actor.weapon_inventory.inventory_data.number_of_slots()
	var traits_in_inventory = InventoryUtils.get_traits(factor_context.target_actor.weapon_inventory.inventory_data)
	
	if !(traits_in_inventory.has(GameItem.ItemTrait.FIREARM) || traits_in_inventory.has(GameItem.ItemTrait.EXPLOSIVE)):
		# a weapon of some kind is required!
		return 1.0
	
	return 1.0 - (number_of_items_in_inventory as float / size_of_inventory as float)
