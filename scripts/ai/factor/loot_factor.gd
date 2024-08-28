class_name LootFactor
extends Factor

# returns a value based on how good the loot is in an area. 0.0 is no loot, higher is a lot of loot
static func calculate(factor_context: FactorContext) -> float:
	var radius: float = 10.0
	var world = factor_context.world
	var items_in_area: Array = world.get_actors_and_gameitems_in_area(factor_context.target_position, radius).filter(func(a): return a is GameItem).filter(func(a): return a != null and !a.is_held and a.can_be_used)
	
	return items_in_area.size() * 0.2
