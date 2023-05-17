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

@onready var rotator: Node3D = get_node("Rotator")
@onready var weapon_base: Node3D = get_node("Rotator/WeaponBase")
@onready var health: Health = get_node("Health")

@export var current_weapon: Weapon

var velocity_to_add: Vector3 = Vector3.ZERO

signal actor_killed(me: Actor)

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
		if current_weapon != null:
			var angle_vector = current_weapon.get_angle_to_aim_at(aim_position)
			weapon_base.look_at(to_global(angle_vector) + (weapon_base.global_position - global_position), Vector3.UP)

func _ready():
	pass

func _process(delta):
	_aim_weapon()
	if (controller.is_shooting() && current_weapon != null):
		current_weapon.fire()

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
	velocity += velocity_to_add * delta
	# zero out the velocity_to_add, as it has been added
	velocity_to_add = Vector3.ZERO

	move_and_slide()

func _on_health_depleted():
	actor_killed.emit(self)
	queue_free()

func _on_hurtbox_was_hit(amount, _hit_position_global, hit_normalized_direction):
	velocity_to_add += hit_normalized_direction * amount * 100.0 * Vector3(1,0,1)
