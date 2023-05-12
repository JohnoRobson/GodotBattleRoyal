class_name PlayerActorController extends ActorController

@onready var aim_position = Vector3.ZERO
@onready var move_direction = Vector2.ZERO

func _process(_delta):
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
	var ray_array = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_origin, ray_end))

	if (ray_array.has("position")):
		return ray_array["position"]
	else:
		return Vector3.ZERO

func is_shooting() -> bool:
	return Input.is_action_pressed("fire")
