extends CharacterBody3D

class_name Actor

@export var speed = 5.0
@export var JUMP_VELOCITY = 4.5
@export var controller: ActorController = ActorController.new()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var movement_direction: Vector3 = Vector3.ZERO
var actor_state: ActorState = ActorState.IDLE

@onready var cursor: ActorCursor = get_node("ActorCursor")
@onready var rotator: Node3D = get_node("Rotator")
@onready var weapon_base: Node3D = get_node("Rotator/Animatable/WeaponBase")
@onready var health: Health = get_node("Health")
@onready var item_pickup_area: ItemInteractionArea = get_node("ItemPickupArea")
@onready var _item_pickup_manager: ItemPickupManager = get_node("ItemPickupManager")
@onready var weapon_inventory: Inventory = get_node("WeaponInventory")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

@export var held_weapon: GameItem

enum ActorState {
	IDLE, WALKING, DEAD
}

# Remove these when proper inventory and item pickups are developed
var _drop_weapon_cooldown_time: float = 0.5
var _drop_weapon_cooldown_timer: float = 0

var _velocity_to_add: Vector3 = Vector3.ZERO

signal actor_killed(me: Actor)
signal weapon_swap(weapon: GameItem)

func _aim_weapon():
	var aim_position = controller.get_aim_position()
	var side_to_side_vector = Vector3(aim_position.x, rotator.global_position.y, aim_position.z)
	
	if !aim_position.is_equal_approx(Vector3.UP) and !side_to_side_vector.is_equal_approx(rotator.global_position):
		# side to side rotation
		rotator.look_at(side_to_side_vector, Vector3.UP)

		# up and down rotation
		if held_weapon != null:
			var angle_vector = held_weapon.get_aim_vector(aim_position)
			weapon_base.look_at(to_global(angle_vector) + (weapon_base.global_position - global_position), Vector3.UP)

func _process(_delta):
	if (actor_state == ActorState.DEAD):
		if (!animation_player.is_playing()): # death animation is over, remove actor
			actor_killed.emit(self)
			queue_free()
		return
	
	cursor.global_position = controller.get_aim_position()
	
	if (_drop_weapon_cooldown_timer > 0.0):
		_drop_weapon_cooldown_timer -= _delta
	_aim_weapon()
	if (controller.is_shooting() && held_weapon != null):
		if held_weapon is Weapon:
			held_weapon.fire()
		else:
			held_weapon.use_item(self)
		weapon_inventory.emit_updates()
	if (controller.is_reloading() && held_weapon != null):
		held_weapon.reload()
	if (held_weapon != null && held_weapon is Weapon):
		held_weapon.set_is_moving(!controller.get_move_direction().is_zero_approx())
	if (controller.is_exchanging_weapon()):
		_try_to_exchange_weapon()
	if (!controller.get_move_direction().is_zero_approx()):
		actor_state = ActorState.WALKING
		if animation_player.current_animation != "walking":
			animation_player.play("walking")
	else:
		actor_state = ActorState.IDLE
		animation_player.play("idle")

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

func _on_health_depleted():
	if held_weapon != null:
		var weapon_position = held_weapon.global_position
		var weapon_rotation = held_weapon.global_rotation
		held_weapon.get_parent().remove_child(held_weapon)
		get_parent().add_child(held_weapon) # this seems like a bad way to do it
		held_weapon.is_held = false
		held_weapon.global_position = weapon_position
		held_weapon.global_rotation = weapon_rotation
	
	actor_state = ActorState.DEAD
	animation_player.play("dead")

func _on_hurtbox_was_hit(amount, _hit_position_global, hit_normalized_direction):
	_velocity_to_add += hit_normalized_direction * amount * 100.0 * Vector3(1,0,1)

# this is for picking up, dropping, or swapping weapons
func _try_to_exchange_weapon():
	if (_drop_weapon_cooldown_timer > 0.0):
		return

	var closest_weapon: GameItem = _item_pickup_manager.get_item_that_cursor_is_over_and_is_in_interaction_range()

	# pick up
	if held_weapon == null && closest_weapon != null:
		weapon_inventory.add_item_to_inventory_from_world(closest_weapon)

	# drop
	elif held_weapon != null && closest_weapon == null:
		weapon_inventory.remove_item_from_inventory_to_world(held_weapon)

	# swap
	elif held_weapon != null && closest_weapon != null:
		weapon_inventory.swap_item_from_world_to_inventory(closest_weapon, held_weapon)
	
	_drop_weapon_cooldown_timer = _drop_weapon_cooldown_time
	# not holding a weapon and there are no weapons nearby
	return

func equip_weapon(weapon: GameItem):
	held_weapon = weapon
	if held_weapon.get_parent() != null:
		held_weapon.get_parent().remove_child(held_weapon)
	weapon_base.add_child(held_weapon)
	held_weapon.position = Vector3.ZERO
	held_weapon.rotation = Vector3.ZERO
	held_weapon.is_held = true
	if held_weapon.item_used_up.is_connected(_on_item_used_up):
		held_weapon.item_used_up.disconnect(_on_item_used_up)
	held_weapon.item_used_up.connect(_on_item_used_up)
	if weapon is Weapon:
		weapon_swap.emit(weapon)

func unequip_weapon():
	if held_weapon.get_parent() != null:
		held_weapon.get_parent().remove_child(held_weapon)
	
	if held_weapon.item_used_up.is_connected(_on_item_used_up):
		held_weapon.item_used_up.disconnect(_on_item_used_up)

	held_weapon = null

func _on_weapon_inventory_inventory_changed(inventory_data: InventoryData, selected_slot_index: int):
	var item_in_selected_slot: GameItem = inventory_data.get_item_at_index(selected_slot_index)

	if (held_weapon == item_in_selected_slot):
		return # do nothing, nothing has changed
	
	if held_weapon != null and item_in_selected_slot != null:
		unequip_weapon()
		equip_weapon(item_in_selected_slot)
	
	if item_in_selected_slot != null:
		equip_weapon(item_in_selected_slot)
	else:
		unequip_weapon()
	
	weapon_swap.emit(held_weapon)

func _on_item_used_up():
	held_weapon = null

func set_camera_current():
	$Camera3D.current = true
