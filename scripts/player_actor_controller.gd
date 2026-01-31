class_name PlayerActorController
extends ActorController

@onready var aim_position = Vector3.ZERO
@onready var move_direction = Vector2.ZERO

const CAMERA_RAYCAST_COLLISION_MASK = 0b0011

func _process(_delta) -> void:
	aim_position = get_mouse_position_in_3d()
	move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

func get_aim_position() -> Vector3:
	return aim_position

func get_move_direction() -> Vector2:
	return move_direction

func get_mouse_position_in_3d() -> Vector3:
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 2000
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, CAMERA_RAYCAST_COLLISION_MASK)
	query.exclude = [get_parent()] # exclude the actor so that you can get things on the other side of the actor
	var result = space_state.intersect_ray(query)
	
	if (result.has("position")):
		return result["position"]
	else:
		return ray_end

func is_shooting() -> bool:
	return Input.is_action_pressed("fire")

func is_reloading() -> bool:
	return Input.is_action_pressed("reload")

func is_exchanging_weapon() -> bool:
	return Input.is_action_pressed("exchange_weapon")
