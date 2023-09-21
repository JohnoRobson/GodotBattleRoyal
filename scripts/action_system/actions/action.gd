class_name Action
extends Resource

var action_name = Name.ACTION
@export var actions: Array[Action] = []

enum Name {
	ACTION,
	AREA,
	DAMAGE,
	CREATE,
	EFFECT,
	HEAL,
	RAYCAST,
	REMOVE,
	REPEAT,
	REPEATDELAY,
	REPLACE,
	TARGETED_ACTION,
	THROW,
	TIMER
}

enum Keys {
	ACTION_SYSTEM,
	POSITION,
	TIMER,
	WORLD
}

func perform(_delta: float, _item_node: ActionStack.ItemNode) -> bool:
	return true

func has_children() -> bool:
	return !actions.is_empty()
