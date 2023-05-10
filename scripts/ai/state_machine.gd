class_name StateMachine

var current_state: State
var owner: AiActorController

func _init(_current_state: State, _owner: AiActorController):
	current_state = _current_state
	owner = _owner

func change_state(new_state: State):
	current_state.exit(owner)
	current_state = new_state
	current_state.enter(owner)

func _physics_process(delta):
	current_state.execute_physics(owner)

func _process(delta):
	current_state.execute(owner)
