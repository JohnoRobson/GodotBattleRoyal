class_name ActionEffect
extends Action

@export var scene_to_spawn: Resource

func _init():
	action_name = self.Name.THROW

func perform(_delta: float, _game_item: GameItem) -> bool:
	var scene = scene_to_spawn.instantiate()
	world.add_child(scene)
	scene.global_position = _game_item.global_position
	return true
