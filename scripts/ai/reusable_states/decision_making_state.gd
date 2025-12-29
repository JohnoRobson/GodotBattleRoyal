class_name DecisionMakingState
extends State

func enter(controller: AiActorController) -> void:
	controller.state_machine.change_state(DecisionMaker.get_state_to_do(controller))

func execute(_controller: AiActorController) -> void:
	pass

func execute_physics(_controller: AiActorController) -> void:
	pass

func exit(_controller: AiActorController) -> void:
	pass

func get_name() -> String:
	return "DecisionMakingState"
