class_name ActionRemove
extends Action

# Removes the parent game item

func _init():
	action_name = self.Name.REMOVE

func perform(_delta: float, item_node: ActionStack.ItemNode) -> bool:
	item_node.game_item.dispose_of_item()
	item_node.game_item = null
	return true
