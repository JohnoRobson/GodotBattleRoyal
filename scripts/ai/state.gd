class_name State

func enter(_controller: AiActorController):
	pass

func execute(_controller: AiActorController):
	pass

func execute_physics(_controller: AiActorController):
	pass

func exit(_controller: AiActorController):
	pass

func get_name() -> String:
	return "State"

func equals(_comparison_state:State):
	return get_name() == _comparison_state.get_name()

func evaluate(_factor_context: FactorContext) -> float:
	return 0.0

## Used for determining if a new state should interrupt the running of this one
## This should return true in most cases
func can_be_interrupted_by(_state: State) -> bool:
	return true
