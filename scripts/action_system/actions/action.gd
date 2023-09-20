class_name Action
extends Resource

var action_name = Name.ACTION
@export var actions: Array[Action] = []
var world: World

enum Name {
	ACTION,
	AREA,
	DAMAGE,
	EFFECT,
	HEAL,
	RAYCAST,
	REMOVE,
	REPEAT,
	REPEATDELAY,
	TARGETED_ACTION,
	THROW,
	TIMER
}

func perform(_delta: float, _game_item: GameItem) -> bool:
	return true

func has_children() -> bool:
	return !actions.is_empty()