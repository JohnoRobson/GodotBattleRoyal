class_name ActionCreate
extends Action

@export var game_item_to_create: Resource

func _init():
	action_name = self.Name.CREATE

func perform(_delta: float, item_node: ActionStack.ItemNode) -> bool:
	print("create")
	var current_game_item: GameItem = item_node.game_item
	var new_game_item = game_item_to_create.instantiate()
	current_game_item.get_parent().add_child(new_game_item)
	new_game_item.position = current_game_item.position
	new_game_item.rotation = current_game_item.rotation
	new_game_item.linear_velocity = current_game_item.linear_velocity
	new_game_item.angular_velocity = current_game_item.angular_velocity

	var action_system: ActionSystem = item_node.data[Action.Keys.ACTION_SYSTEM]
	new_game_item.action_triggered.connect(action_system.action_triggered)
	actions.append_array(new_game_item.action.actions)
	
	return true
