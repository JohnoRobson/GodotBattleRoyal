class_name ActionCreate
extends Action

# Creates a new game item and triggers its first action

@export var game_item_to_create: Resource

func _init():
	action_name = self.Name.CREATE

func perform(_delta: float, item_node: ActionStack.ItemNode) -> bool:
	var current_game_item: GameItem = item_node.game_item
	var new_game_item = game_item_to_create.instantiate()
	item_node.data[Action.Keys.WORLD].return_item_to_world(new_game_item, current_game_item.position, current_game_item.rotation)

	new_game_item.linear_velocity = current_game_item.linear_velocity
	new_game_item.angular_velocity = current_game_item.angular_velocity

	var action_system: ActionSystem = item_node.data[Action.Keys.ACTION_SYSTEM]
	new_game_item.action_triggered.connect(action_system.action_triggered)
	
	item_node.child_nodes.append(ActionStack.ItemNode.new(new_game_item.action, new_game_item, item_node))
	
	return true
