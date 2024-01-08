class_name StateMachine

var current_state: State
var owner: AiActorController

const _decision_seconds_check: float = 0.5
var _decision_seconds_count: float = 0.0

func _init(_current_state: State, _owner: AiActorController):
	current_state = _current_state
	owner = _owner

func change_state(new_state: State):
	current_state.exit(owner)
	current_state = new_state
	current_state.enter(owner)

func _physics_process(_delta):
	current_state.execute_physics(owner)

func _process(_delta):
	if _decision_seconds_count >= _decision_seconds_check:
		_decision_seconds_count = 0.0
		var new_state = DecisionMaker.get_state_to_do(owner)

		if current_state.get_name() != new_state.get_name():
			change_state(new_state)
	else:
		_decision_seconds_count += _delta
		current_state.execute(owner)

func get_current_state_name() -> String:
	return current_state.get_name()
