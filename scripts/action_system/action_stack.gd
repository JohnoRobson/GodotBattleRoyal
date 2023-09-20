class_name ActionStack
extends Resource

@export var uncompleted_top_level_actions: Array[Action] = []
var game_item: GameItem = null

func perform(delta: float):
	if uncompleted_top_level_actions.is_empty():
		return
	var there_are_completable_actions = true
	var current_action_index = 0
	var current_action: Action = uncompleted_top_level_actions[current_action_index]
	while there_are_completable_actions:
		var current_action_is_completed: bool = current_action.perform(delta, game_item)
		if current_action_is_completed:
			if current_action.has_children():
				uncompleted_top_level_actions.append_array(current_action.actions)
			uncompleted_top_level_actions.remove_at(current_action_index)
		else:
			current_action_index += 1
		if current_action_index > uncompleted_top_level_actions.size() - 1:
			there_are_completable_actions = false
			current_action = null
		else:
			current_action = uncompleted_top_level_actions[current_action_index]

func stack_is_completed() -> bool:
	return uncompleted_top_level_actions.is_empty()
