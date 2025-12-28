class_name Action
extends Resource
# Represents a thing that a game item can do
# Actions should not be called directly, but instead passed to a ActionSystem

var action_name = Name.ACTION
@export var actions: Array[Action] = []

# Add a name for new actions here when they are made
enum Name {
	ACTION,
	AREA,
	CREATE,
	DAMAGE,
	EFFECT,
	HEAL,
	RAYCAST,
	REMOVE,
	REPEATDELAY,
	REPEAT,
	REPLACE,
	TARGETED_ACTION,
	THROW,
	TIMER
}

# These are used as keys in the ActionStack.ItemNode's dictionary
enum Keys {
	ACTION_SYSTEM,
	POSITION,
	TIMER,
	WORLD
}

# This is where the logic that an action performs is kept
func perform(_delta: float, _item_node: ActionStack.ItemNode) -> bool:
	return true

func has_children() -> bool:
	return !actions.is_empty()
