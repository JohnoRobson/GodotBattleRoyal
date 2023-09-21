class_name ActionArea
extends Action

@export var radius: float = 1.0
@export var targeted_actions: Array[TargetedAction] = []

func _init():
	action_name = self.Name.AREA

func perform(_delta: float, item_node: ActionStack.ItemNode) -> bool:
	var things_in_area = item_node.data[Action.Keys.WORLD].get_actors_and_gameitems_in_area(item_node.data[Action.Keys.POSITION], radius)
	
	for targeted_action in targeted_actions:
		# do weird array type casting trick
		var node_array: Array[Node3D] = []
		node_array.assign(things_in_area)
		targeted_action.targets = node_array
	
	# do weird array type casting trick
	var action_array: Array[Action] = []
	action_array.assign(targeted_actions)

	# put the targeted actions at the front of the actions for the action system to perform so that they resolve before any child actions
	actions = action_array + actions
	return true
