class_name ActionTimer
extends Action

@export var countdown_in_seconds: float = 1.0
var _time_remaining: float = -1.0

func _init():
	action_name = self.Name.TIMER

func perform(delta: float, _game_item: GameItem) -> bool:
	if _time_remaining == -1.0:
		_time_remaining = countdown_in_seconds
	_time_remaining -= delta
	return _time_remaining <= 0.0
