extends GameItem

class_name Weapon

@export var weapon_damage: float = 10.0
@export_range(0.0, 1200.0, 1.0) var fire_rate_per_minute: float
@export_range(0.0, 180.0, 0.5) var degrees_of_inaccuracy_stationary: float
@export_range(0.0, 180.0, 0.5) var degrees_of_inaccuracy_moving: float
@export_range(0.0, 2000.0, 1.0) var weapon_range: float
@export_range(0.0, 1.0, 0.1) var weapon_reload_time_seconds: float
@onready var fire_rate_per_second = fire_rate_per_minute / 60
@onready var bullet_spawn: Node3D = get_node("BulletPos")
@onready var collision_shape: CollisionShape3D = get_node("CollisionShape3D")

@export_range(0, 500, 1) var _max_ammo: int
@export_range(0, 500, 1) var _current_ammo: int
var _weapon_cooldown_in_seconds: float = 0.0
var _weapon_raycast_collision_mask: int = 0b0011
var _reload_time_cooldown: float = 0.0
var _is_moving: bool = false

enum WeaponState { CAN_FIRE, NO_AMMO, COOLDOWN, RELOADING }

var _current_state: WeaponState = WeaponState.CAN_FIRE

signal on_firing(start_position: Vector3, end_position: Vector3)
signal update_ammo_ui(current_ammo: int, max_ammo: int)

func _process(delta):
	match _current_state:
		WeaponState.CAN_FIRE:
			pass
		WeaponState.NO_AMMO:
			pass
		WeaponState.COOLDOWN:
			_apply_weapon_cooldown(delta)
		WeaponState.RELOADING:
			_apply_weapon_reload(delta)

func reload():
	if _current_state != WeaponState.RELOADING:
		_reload_time_cooldown = weapon_reload_time_seconds
		_current_state = WeaponState.RELOADING

func fire():
	if _current_state == WeaponState.CAN_FIRE:
		_current_ammo = _current_ammo - 1
		update_ammo_ui.emit(_current_ammo, _max_ammo)

		# apply cooldown
		_weapon_cooldown_in_seconds = 1.0 / fire_rate_per_second
		_current_state = WeaponState.COOLDOWN

		# do the raycast
		var aim_vector_local = _make_local_inaccuracy_vector()
		var space_state = get_world_3d().direct_space_state
		var raycast_start_position = bullet_spawn.global_position
		var raycast_end_position = to_global(position + aim_vector_local * weapon_range)
		var query = PhysicsRayQueryParameters3D.create(raycast_start_position, raycast_end_position, _weapon_raycast_collision_mask)
		query.collide_with_areas = true
		query.collide_with_bodies = false
		var result = space_state.intersect_ray(query)

		# apply effect and damage
		if result:
			var raycast_hit_position = result.position
			on_firing.emit(raycast_start_position, raycast_hit_position)
			var target = result.collider
			if target != null:
				if target.is_in_group("Hurtbox"):
					target.take_damage(weapon_damage, raycast_hit_position, (raycast_hit_position - raycast_start_position).normalized())
		else:
			on_firing.emit(raycast_start_position, raycast_end_position)

func _make_local_inaccuracy_vector() -> Vector3:
	# set up the inaccuracy and aim vector for the raycast
	var random = RandomNumberGenerator.new()
	var radians_of_inaccuracy_for_this_shot = deg_to_rad(random.randf_range(-_get_degrees_of_inaccuracy() / 2, _get_degrees_of_inaccuracy() / 2))
	var rotation_angle_of_inaccuracy_for_this_shot = random.randf_range(0.0, PI)
	# get the inaccuracy vector, which is only up and down inaccuracy
	var inaccuracy_vector = Vector3(0, sin(radians_of_inaccuracy_for_this_shot), -cos(radians_of_inaccuracy_for_this_shot))
	# rotate the inaccuracy vector by rotation_angle_of_inaccuracy_for_this_shot
	return inaccuracy_vector.rotated(Vector3.FORWARD, rotation_angle_of_inaccuracy_for_this_shot)

func _get_degrees_of_inaccuracy() -> float:
	return degrees_of_inaccuracy_moving if _is_moving else degrees_of_inaccuracy_stationary

func _apply_weapon_cooldown(delta: float):
	_weapon_cooldown_in_seconds -= delta
	if _weapon_cooldown_in_seconds < 0.0:
		_weapon_cooldown_in_seconds = 0.0
		if (_current_ammo > 0):
			_current_state = WeaponState.CAN_FIRE
		else:
			_current_state = WeaponState.NO_AMMO

func _apply_weapon_reload(delta: float):
	_reload_time_cooldown -= delta
	if _reload_time_cooldown < 0.0:
		_reload_time_cooldown = 0.0
		_current_ammo = _max_ammo
		update_ammo_ui.emit(_current_ammo, _max_ammo)
		_current_state = WeaponState.CAN_FIRE

func get_angle_to_aim_at(target_global_position: Vector3) -> Vector3:
	return target_global_position - global_position

# used for ai checking if the weapon should be reloaded
func empty_and_can_reload() -> bool:
	return _current_state == WeaponState.NO_AMMO

func set_is_moving(is_moving: bool):
	_is_moving = is_moving
