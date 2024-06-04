class_name DecisionMaker

static var top_level_states: Array[State] = [
		FindGrenadeState.new(),
		FindHealthState.new(),
		FleeState.new(),
		FightState.new(),
		FindWeaponState.new(),
		StandInHealingAuraState.new(),
		UseHealthItemState.new()
	]

static func get_state_to_do(controller: AiActorController) -> State:
	var factor_context: FactorContext = FactorContext.new(controller.world, controller.actor, controller.actor.global_position)
	var highest_priority_state = top_level_states[0]
	var highest_priority: float = 0.0
	var print_str: String = "====\n"
	
	# loop through top level states and find out which one has the highest priority
	for state in top_level_states:
		var priority: float = state.evaluate(factor_context)
		if priority > highest_priority:
			highest_priority_state = state
			highest_priority = priority
		print_str = print_str + " %s : %s\n" % [state.get_name(), priority]
	print_str = print_str + "===="
	#print(print_str)

	# return that state
	return highest_priority_state
