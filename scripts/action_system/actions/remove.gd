class_name ActionRemove
extends Action

func _init():
	action_name = self.Name.REMOVE

func perform(_delta: float, game_item: GameItem) -> bool:
	game_item.dispose_of_item()
	return true