class_name DecisionMakingState
extends State

func enter(controller: AiActorController):
	controller.state_machine.change_state(DecisionMaker.get_state_to_do(controller))

func execute(_controller: AiActorController):
	pass

func execute_physics(_controller: AiActorController):
	pass

func exit(_controller: AiActorController):
	pass

func get_name() -> String:
	return "DecisionMakingState"
