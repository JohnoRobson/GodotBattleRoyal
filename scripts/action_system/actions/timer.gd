class_name ActionTimer
extends Action

# Performs its child actions after countdown_in_seconds seconds

@export var countdown_in_seconds: float = 1.0
const timer_key = "TIMER"

func _init():
	action_name = self.Name.TIMER

func perform(delta: float, item_node: ActionStack.ItemNode) -> bool:
	var _time_remaining: float
	if !item_node.data.has(timer_key):
		_time_remaining = countdown_in_seconds
	else:
		_time_remaining = item_node.data[timer_key]
	
	_time_remaining -= delta
	item_node.data[timer_key] = _time_remaining
	return _time_remaining <= 0.0
