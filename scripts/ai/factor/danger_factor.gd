class_name DangerFactor
extends Factor

# returns 0.0 to 1.0 based on how dangerous this actor's position is, based off of enemy actor and grenade proximity. 0.0 is safe, 1.0 is unsafe
static func evaluate(factor_context: FactorContext) -> float:
	const danger_radius: float = 30.0
	const actor_weight = 0.4
	const explosive_weight = 1.0

	var world = factor_context.world
	var actor_position = factor_context.target_actor.global_position
	var nearby_things: Array = world.get_actors_and_gameitems_in_area(actor_position, danger_radius).filter(func(a): return a != factor_context.target_actor)

	if nearby_things.is_empty():
		return 0.0

	var nearby_actors: Array = nearby_things.filter(func(a): return a is Actor)
	var nearby_active_explosives: Array = nearby_things.filter(func(a): return a is GameItem).filter(func(a): return a.has_trait(GameItem.ItemTrait.EXPLOSIVE) and !a.can_be_used and !a.is_held)

	var actor_danger_score = 0.0
	var explosive_danger_score = 0.0

	for actor in nearby_actors:
		var distance_from_actor = actor.global_position.distance_to(actor_position)
		# the further away, the lower the multiplier
		var distance_multiplier = 1.0 - distance_from_actor / danger_radius

		actor_danger_score += actor_weight * distance_multiplier
	
	for explosive in nearby_active_explosives:
		var distance_from_explosive = explosive.global_position.distance_to(actor_position)
		# the further away, the lower the multiplier
		var distance_multiplier = 1.0 - distance_from_explosive / danger_radius

		explosive_danger_score += explosive_weight * distance_multiplier

	return clampf(actor_danger_score + explosive_danger_score, 0.0, 1.0)
