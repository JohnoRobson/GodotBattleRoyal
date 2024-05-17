class_name StandInHealingAuraState
extends State

var is_standing_in_healing_aura: bool = false
var closest_aura: GameItem = null
var ticks_since_entered_aura: int = 0

func enter(controller: AiActorController):
	closest_aura = controller.world.get_closest_healing_aura(controller.actor.global_position)

func execute(controller: AiActorController):
	if closest_aura == null or controller.actor.health.is_max_health():
		controller.state_machine.change_state(DecisionMakingState.new())

func execute_physics(controller: AiActorController):
	if !is_instance_valid(closest_aura) or !is_instance_valid(controller.actor) or controller.actor.health.is_max_health():
		controller.state_machine.change_state(DecisionMakingState.new())
		return
	
	is_standing_in_healing_aura = closest_aura.global_position.distance_to(controller.actor.global_position) <= 2.0
	
	if is_standing_in_healing_aura:
		controller.set_move_direction(Vector2.ZERO)
		ticks_since_entered_aura += 1
	else:
		#move
		controller.nav_agent.target_position = closest_aura.global_transform.origin
		var current_location = controller.actor.global_transform.origin
		var next_location = controller.nav_agent.get_next_path_position()
		var dir = (next_location - current_location).normalized()
		controller.set_move_direction(Vector2(dir.x, dir.z))
		controller.set_aim_position(closest_aura.global_position)
		ticks_since_entered_aura = 0
	
	if ticks_since_entered_aura > 60:
		controller.state_machine.change_state(DecisionMakingState.new())

func exit(controller: AiActorController):
	is_standing_in_healing_aura = false
	closest_aura = null
	ticks_since_entered_aura = 0
	controller.set_move_direction(Vector2.ZERO)

func get_name() -> String:
	return "StandInHealingAuraState"

func evaluate(factor_context: FactorContext) -> float:
	var health_factor: float = HealthFactor.evaluate(factor_context)
	var closest_aura: GameItem = factor_context.world.get_closest_healing_aura(factor_context.target_position)
	
	if closest_aura == null:
		return 0.0
	
	return clampf(health_factor * 2.0, 0.0, 1.0)
