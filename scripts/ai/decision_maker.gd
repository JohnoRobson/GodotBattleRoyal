class_name DecisionMaker

static func get_state_to_do(controller: AiActorController) -> State:
	var state_evaluations := get_states_to_do(controller)
	if state_evaluations.is_empty():
		Logger.error("No valid state evaluations found.")
		assert(false, "No valid state evaluations found.")
		return State.new() # this should not ever get returned
	else:
		return state_evaluations[0].state

## Returns a dictionary of states and their scores sorted from 1 to 0 inclusive
static func get_states_to_do(controller: AiActorController) -> Array[StateEvaluation]:
	var factor_context: FactorContext = FactorContext.new(controller.world, controller.actor, controller.actor.global_position)
	var sorting_states: Dictionary = {}
	#var print_str: String = "====\n"
	
	# has to be created on each call so that we don't share state's states with other states
	var top_level_states: Array[State] = [
		FindAmmoState.new(),
		FindGrenadeState.new(),
		FindHealthState.new(),
		FleeState.new(),
		FightState.new(),
		FindWeaponState.new(),
		StandInHealingAuraState.new(),
		UseHealthItemState.new()
	]
	var sorted_states = top_level_states
	
	# loop through top level states and find out which one has the highest priority
	for state in top_level_states:
		var priority: float = state.evaluate(factor_context)
		sorting_states[state] = priority
		#print_str = print_str + " %s : %s\n" % [state.get_name(), priority]
	#print_str = print_str + "===="
	#print(print_str)
	
	sorted_states.sort_custom(func(a, b): return sorting_states[a] > sorting_states[b])
	
	var return_array: Array[StateEvaluation] = []
	
	for state in sorted_states:
		return_array.append(StateEvaluation.new(state, sorting_states[state]))
	
	return return_array
	
