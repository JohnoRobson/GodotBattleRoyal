extends CharacterBody3D

class_name Actor

@export var speed = 5.0
@export var JUMP_VELOCITY = 4.5
@export var controller: ActorController = ActorController.new()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# the global position that this actor is aiming at
var aimpoint: Vector3 = Vector3.UP
var movement_direction: Vector3 = Vector3.ZERO

@onready var cursor: ActorCursor = get_node("ActorCursor")
@onready var rotator: Node3D = get_node("Rotator")
@onready var weapon_base: Node3D = get_node("Rotator/WeaponBase")
@onready var health: Health = get_node("Health")
@onready var item_pickup_area: ItemInteractionArea = get_node("ItemPickupArea")
@onready var _item_pickup_manager: ItemPickupManager = get_node("ItemPickupManager")
@onready var weapon_inventory: Inventory = get_node("WeaponInventory")

@export var held_weapon: GameItem

# Remove these when proper inventory and item pickups are developed
var _last_held_weapon: GameItem = null
var _last_held_weapon_forget_distance: float = 5.0 # Terrible
var _drop_weapon_cooldown_time: float = 0.5
var _drop_weapon_cooldown_timer: float = 0

var _velocity_to_add: Vector3 = Vector3.ZERO

signal actor_killed(me: Actor)
signal weapon_swap(weapon: Weapon)

# change it so that the item pickup text changes when the aimpoint is on it, via raycast or some collider.
# when the item pickup text changes, the weapon can be picked up

func _aim_at(target_position: Vector3):
	aimpoint = target_position

func _move_direction(input_dir: Vector2):
	movement_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func _aim_weapon():
	var aim_position = controller.get_aim_position()
	if !aim_position.is_equal_approx(Vector3.UP):
		# side to side rotation
		rotator.look_at(aim_position, Vector3.UP)

		# up and down rotation
		if held_weapon != null && held_weapon is Weapon:
			var angle_vector = held_weapon.get_angle_to_aim_at(aim_position)
			weapon_base.look_at(to_global(angle_vector) + (weapon_base.global_position - global_position), Vector3.UP)

func _ready():
	health.take_damage(50)
	pass

func _process(_delta):
	cursor.global_position = controller.get_aim_position()
	
	if (_drop_weapon_cooldown_timer > 0.0):
		_drop_weapon_cooldown_timer -= _delta
	_aim_weapon()
	if (controller.is_shooting() && held_weapon != null):
		if held_weapon is Weapon:
			held_weapon.fire()
		else:
			held_weapon.use_item(self)
	if (controller.is_reloading() && held_weapon != null):
		held_weapon.reload()
	if held_weapon != null && held_weapon is Weapon:
		held_weapon.set_is_moving(!controller.get_move_direction().is_zero_approx())
	if (controller.is_exchanging_weapon()):
		_try_to_exchange_weapon()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var movement_vel = (transform.basis * Vector3(controller.get_move_direction().x, 0, controller.get_move_direction().y)).normalized()
	if movement_vel:
		velocity.x = movement_vel.x * speed
		velocity.z = movement_vel.z * speed
	else:
		# friction
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# velocity from getting shot
	velocity += _velocity_to_add * delta
	# zero out the velocity_to_add, as it has been added
	_velocity_to_add = Vector3.ZERO

	move_and_slide()

# This should be removed once a proper way to pick up items is implemented!
func _equip_weapon_if_it_was_not_recently_dropped():
	# check for collisions for weapon pickups
	var bodies_in_pickup_area: Array[GameItem] = item_pickup_area.get_items_in_area()
	
	# This is bad because it doesn't take the weapon collision box into account
	if (_last_held_weapon != null):
		var distance_from_actor_to_last_held_weapon: float = global_position.distance_to(_last_held_weapon.global_position)
		if (distance_from_actor_to_last_held_weapon > _last_held_weapon_forget_distance):
			_last_held_weapon = null
	
	var nearby_weapons_excluding_dropped = bodies_in_pickup_area.filter(func(a): return a is Weapon && a != _last_held_weapon)
	if !nearby_weapons_excluding_dropped.is_empty() && held_weapon == null:
		equip_weapon(nearby_weapons_excluding_dropped.front())

func _on_health_depleted():
	if held_weapon != null:
		var weapon_position = held_weapon.global_position
		var weapon_rotation = held_weapon.global_rotation
		held_weapon.get_parent().remove_child(held_weapon)
		# this seems like a bad way to do it
		get_parent().add_child(held_weapon)
		held_weapon.is_held = false
		held_weapon.global_position = weapon_position
		held_weapon.global_rotation = weapon_rotation
		
	actor_killed.emit(self)
	queue_free()

func _on_hurtbox_was_hit(amount, _hit_position_global, hit_normalized_direction):
	_velocity_to_add += hit_normalized_direction * amount * 100.0 * Vector3(1,0,1)

# this is for picking up, dropping, or swapping weapons
func _try_to_exchange_weapon():
	if (_drop_weapon_cooldown_timer > 0.0):
		return

	var closest_weapon: GameItem = _item_pickup_manager.get_item_that_cursor_is_over_and_is_in_interaction_range()

	# pick up
	if held_weapon == null && closest_weapon != null:
		equip_weapon(closest_weapon)
	# drop
	elif held_weapon != null && closest_weapon == null:
		drop_weapon()
	# swap
	elif held_weapon != null && closest_weapon != null:
		drop_weapon()
		equip_weapon(closest_weapon)

	_drop_weapon_cooldown_timer = _drop_weapon_cooldown_time
	# not holding a weapon and there are no weapons nearby
	return

func get_closest_weapon_if_exists() -> Weapon:
	# check pickup area for weapon pickups
	var bodies_in_pickup_area: Array[GameItem] = item_pickup_area.get_items_in_area()
	var nearby_weapons: Array[GameItem] = bodies_in_pickup_area.filter(func(a): return a is Weapon)
	nearby_weapons.sort_custom(func(a, b): return global_transform.origin.distance_to(a.global_transform.origin) < global_transform.origin.distance_to(b.global_transform.origin))
	
	var closest_weapon: Weapon = null if nearby_weapons.is_empty() else nearby_weapons.front()
	return closest_weapon

func equip_weapon(weapon: GameItem):
	held_weapon = weapon
	if held_weapon.get_parent() != null:
		held_weapon.get_parent().remove_child(held_weapon)
	weapon_base.add_child(held_weapon)
	held_weapon.position = Vector3.ZERO
	held_weapon.rotation = Vector3.ZERO
	held_weapon.is_held = true
	if weapon is Weapon:
		weapon_swap.emit(weapon)
	_last_held_weapon = null

func drop_weapon():
	if (held_weapon == null || _drop_weapon_cooldown_timer > 0.0):
		return
	held_weapon.position = Vector3.ZERO
	held_weapon.rotation = Vector3.ZERO
	held_weapon.get_parent().remove_child(held_weapon)

	# this is hacky
	get_parent().add_child(held_weapon)
	_last_held_weapon = held_weapon
	held_weapon.global_position = position + Vector3.UP * 1
	held_weapon.set_global_rotation_degrees(Vector3(0, 90, 0))
	held_weapon.is_held = false
	held_weapon = null
