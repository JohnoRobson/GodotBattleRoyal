class_name FactorContext

var world: World
var target_actor: Actor
var target_position: Vector3

func _init(_world: World, _target_actor: Actor, _target_position: Vector3):
	world = _world
	target_actor = _target_actor
	target_position = _target_position
