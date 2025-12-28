class_name Weapon
extends GameItem

@export var stats: WeaponType
@onready var _fire_rate_per_second = stats.fire_rate_per_minute / 60

var _ammo: Ammo
var _weapon_cooldown_in_seconds: float = 0.0
var _reload_time_cooldown: float = 0.0
var _is_moving: bool = false

enum WeaponState { CAN_FIRE, NO_AMMO, COOLDOWN, RELOADING }

var _current_state: WeaponState = WeaponState.NO_AMMO

signal update_ammo_ui(current_ammo: int, max_ammo: int)
#signal on_firing(start_position: Vector3, end_position: Vector3)

func _ready() -> void:
	# big hack, but it works for now
	if (action is ActionRaycast):
		(action as ActionRaycast).cast_degrees_of_inaccuracy = get_degrees_of_inaccuracy
	elif (action is ActionRepeat and action.action_to_repeat != null and action.action_to_repeat is ActionRaycast):
		(action.action_to_repeat as ActionRaycast).cast_degrees_of_inaccuracy = get_degrees_of_inaccuracy

func _process(delta) -> void:
	match _current_state:
		WeaponState.CAN_FIRE:
			pass
		WeaponState.NO_AMMO:
			pass
		WeaponState.COOLDOWN:
			_apply_weapon_cooldown(delta)
		WeaponState.RELOADING:
			_apply_weapon_reload(delta)

func does_slot_contain_compatible_ammo(slot: InventorySlotData) -> bool:
	var item_in_slot: GameItem = slot.get_item()
	if item_in_slot == null or !(item_in_slot is Ammo):
		return false
	return (item_in_slot as Ammo).ammo_type.ammo_category == stats.ammo_category

# attempts to start the reload process. returns false if there is no ammo to reload with
func reload(inventory: Inventory) -> bool:
	# return if we are already in the process of reloading
	if _current_state == WeaponState.RELOADING:
		return true
	
	# check inventory for ammo of the right type if it exists, take the first one found and delete it, then start the reload process
	var ammo_in_inventory: GameItem = inventory.subtract_item_matching(func(a): return does_slot_contain_compatible_ammo(a))
	if ammo_in_inventory != null:
		_reload_time_cooldown = stats.weapon_reload_time_seconds
		_current_state = WeaponState.RELOADING
		_ammo = ammo_in_inventory
		return true
	return false

# fires the weapon, if it can
func fire() -> void:
	if _current_state == WeaponState.CAN_FIRE and _ammo != null:
		_ammo.current_ammo_in_magazine -= 1
		update_ammo_ui.emit(_ammo.current_ammo_in_magazine, _ammo.ammo_type.ammo_in_full_magazine)
		
		# apply cooldown
		_weapon_cooldown_in_seconds = 1.0 / _fire_rate_per_second
		_current_state = WeaponState.COOLDOWN
		action_triggered.emit(action, self)

func get_degrees_of_inaccuracy() -> float:
	return stats.degrees_of_inaccuracy_moving if _is_moving else stats.degrees_of_inaccuracy_stationary

func _apply_weapon_cooldown(delta: float) -> void:
	_weapon_cooldown_in_seconds -= delta
	if _weapon_cooldown_in_seconds < 0.0:
		_weapon_cooldown_in_seconds = 0.0
		if (_ammo != null and _ammo.current_ammo_in_magazine > 0):
			_current_state = WeaponState.CAN_FIRE
		else:
			_current_state = WeaponState.NO_AMMO

func _apply_weapon_reload(delta: float) -> void:
	_reload_time_cooldown -= delta
	if _reload_time_cooldown <= 0.0:
		_reload_time_cooldown = 0.0
		assert(_ammo != null)
		update_ammo_ui.emit(_ammo.current_ammo_in_magazine, _ammo.ammo_type.ammo_in_full_magazine)
		_current_state = WeaponState.CAN_FIRE

# used for ai checking if the weapon should be reloaded
func empty_and_can_reload() -> bool:
	return _current_state == WeaponState.NO_AMMO

# used by the actor holding the weapon to toggle the movement penalty for accuracy
func set_is_moving(is_moving: bool) -> void:
	_is_moving = is_moving
