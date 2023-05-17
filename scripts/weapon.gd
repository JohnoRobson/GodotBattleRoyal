extends Node3D

class_name Weapon

@export var weapon_damage = 10.0
@export_range(0.0, 1200.0, 1.0) var fire_rate_per_minute
@export_range(0.0, 180.0, 0.5) var degrees_of_inaccuracy
@onready var fire_rate_per_second = fire_rate_per_minute / 60
@onready var bullet_spawn: Node3D = get_node("BulletPos")
@onready var collision_shape: CollisionShape3D = get_node("CollisionShape3D")
var _current_ammo: int = 0
var _max_ammo: int = 30
var _is_currently_held: bool = true
var _weapon_cooldown = 0.0
var _can_shoot: bool = true

signal on_firing(start_position, end_position)

func _process(delta):
	_apply_weapon_cooldown(delta)

func _physics_process(_delta):
	collision_shape.disabled = _is_currently_held

func fire():
	#_is_currently_held = true
	if _can_shoot:
		# apply cooldown
		_weapon_cooldown = 1.0 / fire_rate_per_second
		_can_shoot = false

		# set up the inaccuracy and aim vector for the raycast
		# math only allows for extremes atm, but I'm sleepy
		var radians_of_inaccuracy = deg_to_rad(degrees_of_inaccuracy)
		var random = RandomNumberGenerator.new()
		var x_inaccuracy = random.randf_range(-radians_of_inaccuracy / 2, radians_of_inaccuracy / 2)
		var y_inaccuracy = clamp(
			random.randf_range(-radians_of_inaccuracy / 2, radians_of_inaccuracy / 2),
			-radians_of_inaccuracy - absf(x_inaccuracy),
			radians_of_inaccuracy - absf(x_inaccuracy)
			)
		var aim_vector_local = Vector3(x_inaccuracy, y_inaccuracy, 0) + Vector3.FORWARD
		var space_state = get_world_3d().direct_space_state

		# do the raycast
		var query = PhysicsRayQueryParameters3D.create(bullet_spawn.global_position, to_global(position + aim_vector_local * 1000), 0b0011)
		query.collide_with_areas = true
		query.collide_with_bodies = false
		var result = space_state.intersect_ray(query)

		# apply effect and damage
		if result:
			var start_p = bullet_spawn.global_position
			var end_p = result.position
			on_firing.emit(start_p, end_p)
			var target = result.collider
			if target != null:
				if target.is_in_group("Hurtbox"):
					target.take_damage(weapon_damage, end_p, (end_p - start_p).normalized())
		else:
			var start_p = bullet_spawn.global_position
			var end_p = to_global(position + aim_vector_local * 1000)
			on_firing.emit(start_p, end_p)

func _apply_weapon_cooldown(delta: float):
	_weapon_cooldown -= delta
	if _weapon_cooldown < 0.0:
		_weapon_cooldown = 0.0
		_can_shoot = true

func get_angle_to_aim_at(target_global_position: Vector3) -> Vector3:
	return target_global_position - global_position
