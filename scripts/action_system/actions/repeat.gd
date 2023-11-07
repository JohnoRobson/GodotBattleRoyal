class_name ActionRepeat
extends Action

# Repeats the its action_to_repeat a number of times

@export var number_of_times_to_repeat: int = 1
@export var action_to_repeat: Action

func _init():
	action_name = self.Name.REPEAT

func perform(_delta: float, item_node: ActionStack.ItemNode) -> bool:
	for i in number_of_times_to_repeat:
		var action = action_to_repeat.duplicate(true)
		item_node.child_nodes.append(ActionStack.ItemNode.new(action, item_node.game_item, item_node))

	return true
