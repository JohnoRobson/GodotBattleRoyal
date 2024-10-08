extends GameItem

class_name Weapon

@export var stats: WeaponType
@onready var _current_ammo: int = stats.max_ammo
@onready var _fire_rate_per_second = stats.fire_rate_per_minute / 60

var _weapon_cooldown_in_seconds: float = 0.0
var _reload_time_cooldown: float = 0.0
var _is_moving: bool = false

enum WeaponState { CAN_FIRE, NO_AMMO, COOLDOWN, RELOADING }

var _current_state: WeaponState = WeaponState.CAN_FIRE

# used for drawing the raycast
signal on_firing(start_position: Vector3, end_position: Vector3)
signal update_ammo_ui(current_ammo: int, max_ammo: int)

func _ready():
	# big hack, but it works for now
	if (action is ActionRaycast):
		(action as ActionRaycast).cast_degrees_of_inaccuracy = get_degrees_of_inaccuracy
	elif (action is ActionRepeat and action.action_to_repeat != null and action.action_to_repeat is ActionRaycast):
		(action.action_to_repeat as ActionRaycast).cast_degrees_of_inaccuracy = get_degrees_of_inaccuracy

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
		action_triggered.emit(action, self)

func get_degrees_of_inaccuracy() -> float:
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
