class_name Factors

static func clamp_result(value: float) -> float:
	return clampf(value, 0.0, 1.0)

## returns 0.0 to 1.0 based on how dangerous this actor's position is, based off of enemy actor proximity. 0.0 is safe, 1.0 is unsafe
static func evaluate_danger_factor(factor_context: FactorContext) -> float:
	const danger_radius: float = 5.0
	const actor_weight = 0.4

	var world = factor_context.world
	var actor_position = factor_context.target_actor.global_position
	var nearby_things: Array = world.get_actors_and_gameitems_in_area(actor_position, danger_radius).filter(func(a): return a != factor_context.target_actor)

	if nearby_things.is_empty():
		return 0.0

	var nearby_actors: Array = nearby_things.filter(func(a): return a is Actor)

	var actor_danger_score = 0.0

	for actor in nearby_actors:
		var distance_from_actor = actor.global_position.distance_to(actor_position)
		# the further away, the lower the multiplier
		var distance_multiplier = 1.0 - distance_from_actor / danger_radius

		actor_danger_score += actor_weight * distance_multiplier
	
	return clamp_result(actor_danger_score)

## returns 0.0 to 1.0 based off of how poorly-equipped the actor is, with 0.0 being a full inventory and 1.0 being empty or not having a weapon
static func evaluate_equipment_factor(factor_context: FactorContext) -> float:
	var number_of_items_in_inventory = factor_context.target_actor.inventory.number_of_filled_slots()
	var size_of_inventory = factor_context.target_actor.inventory.inventory_data.number_of_slots()
	var traits_in_inventory = InventoryUtils.get_traits(factor_context.target_actor.inventory.inventory_data)
	
	if !(traits_in_inventory.has(GameItem.ItemTrait.FIREARM) || traits_in_inventory.has(GameItem.ItemTrait.EXPLOSIVE)):
		# a weapon of some kind is required!
		return 1.0
	
	return clamp_result(1.0 - (number_of_items_in_inventory as float / size_of_inventory as float))

## returns 0.0 to 1.0 based on how much importance an actor should put on thier health. 0.0 is full health, 1.0 is almost no health
static func evaluate_health_factor(factor_context: FactorContext) -> float:
	var max_health = factor_context.target_actor.health.max_health
	var current_health = factor_context.target_actor.health.current_health

	return clamp_result(1.0 - (current_health / max_health))

## returns 0.0 to 1.0 based on how good the loot is in an area. 0.0 is no loot, 1.0 is a lot of loot
static func evaluate_loot_factor(factor_context: FactorContext) -> float:
	var radius: float = 10.0
	var world = factor_context.world
	var items_in_area: Array = world.get_actors_and_gameitems_in_area(factor_context.target_position, radius).filter(func(a): return a is GameItem).filter(func(a): return a != null and !a.is_held and a.can_be_used)

	return clamp_result(items_in_area.size() * 0.2)

# returns 0.0 to 1.0 based on how dangerous this actor's position is based off grenade proximity. 0.0 is safe, 1.0 is unsafe
static func evaluate_nearby_explosives_factor(factor_context: FactorContext) -> float:
	const danger_radius: float = 5.0
	const explosive_weight = 4.0

	var world = factor_context.world
	var actor_position = factor_context.target_actor.global_position
	var nearby_things: Array = world.get_actors_and_gameitems_in_area(actor_position, danger_radius).filter(func(a): return a != factor_context.target_actor)

	if nearby_things.is_empty():
		return 0.0

	var nearby_active_explosives: Array = nearby_things.filter(func(a): return a is GameItem).filter(func(a): return a.has_trait(GameItem.ItemTrait.EXPLOSIVE) and !a.can_be_used and !a.is_held)

	var explosive_danger_score = 0.0
	
	for explosive in nearby_active_explosives:
		var distance_from_explosive = explosive.global_position.distance_to(actor_position)
		# the further away, the lower the multiplier
		var distance_multiplier = 1.0 - distance_from_explosive / danger_radius
		
		explosive_danger_score += explosive_weight * distance_multiplier
	
	return clamp_result(explosive_danger_score)
