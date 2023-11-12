class_name HealthFactor
extends Factor

# returns 0.0 to 1.0 based on how much importance an actor should put on thier health. 0.0 is full health, 1.0 is almost no health
static func evaluate(factor_context: FactorContext) -> float:
	var max_health = factor_context.target_actor.health.max_health
	var current_health = factor_context.target_actor.health.current_health

	return clampf(1.0 - (current_health / max_health), 0.0, 1.0)