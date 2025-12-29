class_name StateMachine

var current_state: State
var last_state: State
var owner: AiActorController

var previous_state_evaluations: StateEvaluationMemory

const _decision_seconds_check: float = 0.5
var _decision_seconds_count: float = 0.0
const _how_long_until_state_switchback_is_allowed: float = 4.0
var _state_switchback_count: float = 0.0
const _number_of_memory_frames_to_keep: int = 5

func _init(_current_state: State, _owner: AiActorController) -> void:
	current_state = _current_state
	owner = _owner
	previous_state_evaluations = StateEvaluationMemory.new(_number_of_memory_frames_to_keep)

func change_state(new_state: State) -> void:
	current_state.exit(owner)
	current_state = new_state
	current_state.enter(owner)

func _physics_process(_delta) -> void:
	current_state.execute_physics(owner)

func _process(delta) -> void:
	if _decision_seconds_count >= _decision_seconds_check:
		_decision_seconds_count = 0.0
		var states: Array[StateEvaluation] = DecisionMaker.get_states_to_do(owner)
		previous_state_evaluations.push_evaluations(states)
		var best_state = states[0].state
		
		var last_state_is_the_same_as_new_best_state: bool = last_state != null and last_state.equals(best_state)
		
		if last_state_is_the_same_as_new_best_state and _state_switchback_count < _how_long_until_state_switchback_is_allowed:
			best_state = states[1].state

		if !current_state.equals(best_state) and current_state.can_be_interrupted_by(best_state):
			#print("switching from %s to %s" % [current_state.get_name(), best_state.get_name()])
			last_state = current_state
			_state_switchback_count = 0
			change_state(best_state)
	else:
		_decision_seconds_count += delta
		current_state.execute(owner)
	
	_state_switchback_count += delta

func get_current_state_name() -> String:
	return current_state.get_name()
