class_name PlayerCamera extends Node3D

# The origin of this node is assumed to be at ground level
# The purpose of this node is to pan the camera around to follow the player's
# mouse in such a way that the edges of the viewport never reveal the game further than
# x distance away, taking the orientation and fov of the camera into account.
#
# This will not be a perfect solution to the corners of the screen being able
# to see slightly further than the edges, but it will be better than nothing.
#
# 

@export var camera: Camera3D
@export var max_distance_from_center: float = 50

var _panning_rect: Rect2
var _bounding_rect: Rect2
var _pan_target_pos: Vector2
var _camera_offset: Vector3

var mouse_pos: Vector2 = Vector2()

enum _Axis {
	X, Y
}

func _get_angle_of_ray(ray: Vector3, axis: _Axis) -> float:
	var down = Vector3.DOWN
	match axis:
		_Axis.X:
			return rad_to_deg(down.angle_to(Vector3(ray.x, ray.y, 0)))
		_:
			return rad_to_deg(down.angle_to(Vector3(0, ray.y, ray.z)))

func calculate_panning_rect() -> Rect2:
	return Rect2(Vector2(), Vector2(38, 33))

func pan_to(pos: Vector2) -> void:
	camera.position = Vector3(pos.x + _camera_offset.x, _camera_offset.y, pos.y + _camera_offset.z)
	pass

func make_current() -> void:
	camera.make_current()

func _ready() -> void:
	_panning_rect = calculate_panning_rect()
	_camera_offset = camera.position
	_bounding_rect = Rect2(Vector2(), Vector2(max_distance_from_center, max_distance_from_center))

func _process(_delta: float) -> void:
	var viewport = get_viewport()
	var mouse_position = viewport.get_mouse_position() # zzz making this not directly call the viewport
	
	var clamped_mouse_pos = Vector2(clampf(mouse_position.x, 0, viewport.get_visible_rect().size.x), clampf(mouse_position.y, 0, viewport.get_visible_rect().size.y))
	
	var centered_mouse_pos =  clamped_mouse_pos - (viewport.get_visible_rect().size / 2)
	# assume the shortest side of the screen to be the height
	var normalized_mouse_pos = centered_mouse_pos * 2 / viewport.get_visible_rect().size.x
	
	# rect in rect
	# get margins
	var width = (_bounding_rect.size.x - _panning_rect.size.x) / 2
	var height = (_bounding_rect.size.y - _panning_rect.size.y) / 2
	
	var multiplied_mouse_position = Vector2(width, height) * normalized_mouse_pos
	var mag = multiplied_mouse_position.length()
	var clamped_multiplied_mouse_position = multiplied_mouse_position.normalized() * mag
	
	pan_to(clamped_multiplied_mouse_position)
	pass
