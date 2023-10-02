extends GameItem

class_name Weapon

@export var stats: WeaponType
@onready var _current_ammo: int = stats.max_ammo
@onready var _fire_rate_per_second = stats.fire_rate_per_minute / 60

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

# starts the reload process
func reload():
	if _current_state != WeaponState.RELOADING:
		_reload_time_cooldown = stats.weapon_reload_time_seconds
		_current_state = WeaponState.RELOADING

# fires the weapon, if it can
func fire():
	if _current_state == WeaponState.CAN_FIRE:
		_current_ammo = _current_ammo - 1
		update_ammo_ui.emit(_current_ammo, stats.max_ammo)

		# apply cooldown
		_weapon_cooldown_in_seconds = 1.0 / _fire_rate_per_second
		_current_state = WeaponState.COOLDOWN

		for i in stats.number_of_shots_per_fire:
			# do the raycast
			var aim_vector_local = VectorUtils.make_local_inaccuracy_vector(_get_degrees_of_inaccuracy())
			var space_state = get_world_3d().direct_space_state
			var raycast_start_position = to_global(stats.bullet_spawn_position_local)
			var raycast_end_position = to_global(position + aim_vector_local * stats.weapon_range)
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
						target.take_damage(stats.weapon_damage, raycast_hit_position, (raycast_hit_position - raycast_start_position).normalized())
			else:
				on_firing.emit(raycast_start_position, raycast_end_position)

func _get_degrees_of_inaccuracy() -> float:
	return stats.degrees_of_inaccuracy_moving if _is_moving else stats.degrees_of_inaccuracy_stationary

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
		_current_ammo = stats.max_ammo
		update_ammo_ui.emit(_current_ammo, stats.max_ammo)
		_current_state = WeaponState.CAN_FIRE

# used for ai checking if the weapon should be reloaded
func empty_and_can_reload() -> bool:
	return _current_state == WeaponState.NO_AMMO

# used by the actor holding the weapon to toggle the movement penalty for accuracy
func set_is_moving(is_moving: bool):
	_is_moving = is_moving
