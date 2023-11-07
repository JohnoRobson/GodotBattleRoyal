extends Resource
class_name WeaponType

@export_range(0.0, 1200.0, 1.0) var fire_rate_per_minute: float
@export_range(0.0, 180.0, 0.5) var degrees_of_inaccuracy_stationary: float
@export_range(0.0, 180.0, 0.5) var degrees_of_inaccuracy_moving: float
@export_range(0.0, 100.0, 0.1) var weapon_reload_time_seconds: float
@export_range(0, 50, 1) var number_of_shots_per_fire: int
@export_range(0, 500, 1) var max_ammo: int
