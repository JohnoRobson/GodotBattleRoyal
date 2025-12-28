class_name ActionReplace
extends Action
# Replaces the current game item with the replacement_game_item

@export var replacement_game_item: PackedScene

func _init() -> void:
	action_name = self.Name.REPLACE

func perform(_delta: float, item_node: ActionStack.ItemNode) -> bool:
	var current_game_item: GameItem = item_node.game_item
	var new_game_item = replacement_game_item.instantiate()
	item_node.data[Action.Keys.WORLD].return_item_to_world(new_game_item, current_game_item.position, current_game_item.rotation)
	new_game_item.linear_velocity = current_game_item.linear_velocity
	new_game_item.angular_velocity = current_game_item.angular_velocity
	
	var action_system: ActionSystem = item_node.data[Action.Keys.ACTION_SYSTEM]
	new_game_item.action_triggered.connect(action_system.action_triggered)
	
	item_node.game_item = new_game_item
	actions.append_array(new_game_item.action.actions)
	
	current_game_item.queue_free()
	
	return true
