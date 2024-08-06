class_name StateMachine

var current_state: State
var last_state: State
var owner: AiActorController

const _decision_seconds_check: float = 0.5
var _decision_seconds_count: float = 0.0
const _how_long_until_state_switchback_is_allowed: float = 4.0
var _state_switchback_count: float = 0.0

func _init(_current_state: State, _owner: AiActorController):
	current_state = _current_state
	owner = _owner

func change_state(new_state: State):
	current_state.exit(owner)
	current_state = new_state
	current_state.enter(owner)

func _physics_process(_delta):
	current_state.execute_physics(owner)

func _process(delta):
	if _decision_seconds_count >= _decision_seconds_check:
		_decision_seconds_count = 0.0
		var states = DecisionMaker.get_states_to_do(owner)
		var best_state = states[0]
		
		var last_state_is_the_same_as_new_best_state: bool = last_state != null and last_state.get_name() == best_state.get_name()
		
		if last_state_is_the_same_as_new_best_state and _state_switchback_count < _how_long_until_state_switchback_is_allowed:
			best_state = states[1]

		if current_state.get_name() != best_state.get_name() and current_state.can_be_interrupted_by(best_state):
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
