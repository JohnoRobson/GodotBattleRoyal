class_name ActionThrow
extends Action

@export var degrees_of_inaccuracy: float = 1.0
@export var force: float = 1

func _init():
	action_name = self.Name.EFFECT

func perform(_delta: float, game_item: GameItem) -> bool:
	game_item.remove_from_inventory_and_put_in_world.emit(game_item)
	var throw_direction = VectorUtils.make_local_inaccuracy_vector(degrees_of_inaccuracy)
	game_item.global_position = game_item.to_global(Vector3.FORWARD)
	game_item.linear_velocity = game_item.to_global(throw_direction * force)

	return true