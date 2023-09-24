class_name ActionThrow
extends Action

@export var degrees_of_inaccuracy: float = 1.0
@export var force: float = 1

func _init():
	action_name = self.Name.THROW

func perform(_delta: float, item_node: ActionStack.ItemNode) -> bool:
	var game_item: GameItem = item_node.game_item
	game_item.remove_from_inventory_and_put_in_world.emit(game_item)
	var throw_direction = VectorUtils.make_local_inaccuracy_vector(degrees_of_inaccuracy)
	game_item.global_position = game_item.global_position
	game_item.linear_velocity = game_item.to_global(throw_direction * force)
	game_item.can_be_used = false
	
	return true
