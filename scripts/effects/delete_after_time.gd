extends Node3D
# Deletes itself after lifetime_seconds

@export_range(0.0, 10.0, 0.1) var lifetime_seconds:float = 2

var _lifetime_remaining: float

func _ready():
	_lifetime_remaining = lifetime_seconds

func _process(delta):
	_lifetime_remaining -= delta
	
	if _lifetime_remaining <= 0.0:
		queue_free()
