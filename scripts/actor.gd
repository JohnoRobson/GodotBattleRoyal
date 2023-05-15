extends CharacterBody3D

class_name Actor

@export var speed = 5.0
@export var JUMP_VELOCITY = 4.5
@export var weapon_damage = 10.0
@export var controller: ActorController = ActorController.new()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# the global position that this actor is aiming at
var aimpoint: Vector3 = Vector3.UP
var movement_direction: Vector3 = Vector3.ZERO

@onready var rotator: Node3D = get_node("Rotator")
@onready var weapon_base: Node3D = get_node("Rotator/WeaponBase")
@onready var health: Health = get_node("Health")
@onready var weapon_raycast: RayCast3D = get_node("Rotator/WeaponBase/PlaceholderWeapon/RayCast3D")

@export_range(0.0, 1200.0, 1.0) var fire_rate_per_minute
@onready var fire_rate_per_second = fire_rate_per_minute / 60
var weapon_cooldown = 0.0
var can_shoot: bool = true

var velocity_to_add: Vector3 = Vector3.ZERO

signal shoot(start_position, end_position)
signal actor_killed(me: Actor)

func _aim_at(target_position: Vector3):
	aimpoint = target_position

func _move_direction(input_dir: Vector2):
	movement_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func _aim_weapon():
	var aim_position = controller.get_aim_position()
	if aim_position != Vector3.UP:
		# side to side rotation
		rotator.look_at(aim_position, Vector3.UP)

		# up and down rotation
		weapon_base.look_at(aim_position, Vector3.UP)

func _shoot():
	if can_shoot:
		# apply cooldown
		weapon_cooldown = 1.0 / fire_rate_per_second
		can_shoot = false

		if weapon_raycast.is_colliding():
			var start_p = weapon_raycast.global_position
			var end_p = weapon_raycast.get_collision_point()
			shoot.emit(start_p, end_p)
			var target = weapon_raycast.get_collider()
			if target != null:
				if target.is_in_group("Hurtbox"):
					target.take_damage(weapon_damage, end_p, (end_p - start_p).normalized())
		else:
			var start_p = weapon_raycast.global_position
			var end_p = weapon_raycast.to_global(weapon_raycast.target_position)
			shoot.emit(start_p, end_p)

func _apply_weapon_cooldown(delta: float):
	weapon_cooldown -= delta
	if weapon_cooldown < 0.0:
		weapon_cooldown = 0.0
		can_shoot = true

func _ready():
	pass

func _process(delta):
	_aim_weapon()
	_apply_weapon_cooldown(delta)
	if (controller.is_shooting()):
		_shoot()

func _physics_process(delta):
	# velocity from getting shot
	velocity += velocity_to_add * delta
	velocity_to_add = Vector3.ZERO

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var movement_vel = (transform.basis * Vector3(controller.get_move_direction().x, 0, controller.get_move_direction().y)).normalized()
	if movement_vel:
		velocity.x = movement_vel.x * speed
		velocity.z = movement_vel.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _on_health_depleted():
	print(self)
	actor_killed.emit(self)
	queue_free()

func _on_hurtbox_was_hit(amount, _hit_position_global, hit_normalized_direction):
	velocity_to_add += hit_normalized_direction * amount * 100.0
