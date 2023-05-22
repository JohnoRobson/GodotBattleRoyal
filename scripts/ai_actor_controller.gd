class_name AiActorController extends ActorController

@export var actor: AiActor
@export var world_navmesh: NavigationRegion3D
@export var world: World

var state_machine: StateMachine
var aim_position: Vector3 = Vector3.ZERO
var move_direction: Vector2 = Vector2.ZERO
var is_shooting_bool: bool = false
var is_reloading_bool: bool = false
var current_target: Actor = null

func _process(delta):
	state_machine._process(delta)
	pass

func _physics_process(delta):
	state_machine._physics_process(delta)
	pass

func get_aim_position() -> Vector3:
	return aim_position

func get_move_direction() -> Vector2:
	return move_direction

func is_shooting() -> bool:
	return is_shooting_bool

func set_aim_position(new_aim_position: Vector3):
	aim_position = new_aim_position

func set_move_direction(dir: Vector2):
	if (dir.is_normalized()):
		move_direction = dir
	else:
		move_direction = dir.normalized()

func set_is_shooting(shoot: bool):
	is_shooting_bool = shoot

func is_reloading() -> bool:
	return is_reloading_bool

func set_is_reloading(reload: bool):
	is_reloading_bool = reload
