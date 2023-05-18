extends GameItem

class_name Weapon

@export var weapon_damage: float = 10.0
@export_range(0.0, 1200.0, 1.0) var fire_rate_per_minute: float
@export_range(0.0, 180.0, 0.5) var degrees_of_inaccuracy: float
@export_range(0.0, 2000.0, 1.0) var weapon_range: float
@onready var fire_rate_per_second = fire_rate_per_minute / 60
@onready var bullet_spawn: Node3D = get_node("BulletPos")
@onready var collision_shape: CollisionShape3D = get_node("CollisionShape3D")
var _current_ammo: int = 0 # not used yet
var _max_ammo: int = 30 # not used yet
var _weapon_cooldown_in_seconds: float = 0.0
var _can_shoot: bool = true
var _weapon_raycast_collision_mask: int = 0b0011

signal on_firing(start_position, end_position)

func _process(delta):
	_apply_weapon_cooldown(delta)

func fire():
	if _can_shoot:
		# apply cooldown
		_weapon_cooldown_in_seconds = 1.0 / fire_rate_per_second
		_can_shoot = false

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
	var radians_of_inaccuracy_for_this_shot = deg_to_rad(random.randf_range(-degrees_of_inaccuracy / 2, degrees_of_inaccuracy / 2))
	var rotation_angle_of_inaccuracy_for_this_shot = random.randf_range(0.0, PI)
	# get the inaccuracy vector, which is only up and down inaccuracy
	var inaccuracy_vector = Vector3(0, sin(radians_of_inaccuracy_for_this_shot), -cos(radians_of_inaccuracy_for_this_shot))
	# rotate the inaccuracy vector by rotation_angle_of_inaccuracy_for_this_shot
	return inaccuracy_vector.rotated(Vector3.FORWARD, rotation_angle_of_inaccuracy_for_this_shot)

func _apply_weapon_cooldown(delta: float):
	_weapon_cooldown_in_seconds -= delta
	if _weapon_cooldown_in_seconds < 0.0:
		_weapon_cooldown_in_seconds = 0.0
		_can_shoot = true

func get_angle_to_aim_at(target_global_position: Vector3) -> Vector3:
	return target_global_position - global_position
