class_name ActionEffect
extends Action

# Creates a scene at the current location. This is intended for instantiating effects that will clean themselves up

@export var scene_to_spawn: Resource

func _init():
	action_name = self.Name.EFFECT

func perform(_delta: float, item_node: ActionStack.ItemNode) -> bool:
	var scene = scene_to_spawn.instantiate()
	item_node.data[Action.Keys.WORLD].add_child(scene)
	scene.global_position = item_node.data.get(self.Keys.POSITION)
	return true
