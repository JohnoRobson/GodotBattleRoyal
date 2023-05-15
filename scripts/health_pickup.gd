extends Node3D

class_name HealthPickup

@export var indicator: MeshInstance3D
@export var area: Area3D
@export_range(1.0, 100.0, 1) var healing = 50.0
@export_range(1.0, 60.0, 1) var respawn_time_in_seconds = 10.0
var seconds_until_respawn: float = 0
var health_is_available: bool

func _ready():
	health_is_available = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (!health_is_available):
		seconds_until_respawn -= delta
		if (seconds_until_respawn <= 0.0):
			enable_health_pickup()

func enable_health_pickup():
	seconds_until_respawn = 0
	health_is_available = true
	indicator.show()

func disable_health_pickup(actor: Actor):
	seconds_until_respawn = respawn_time_in_seconds
	health_is_available = false
	indicator.hide()
	actor.health.take_damage(-healing)

func _on_area_3d_body_entered(body: Node3D):
	if (body.is_in_group("actors")):
		disable_health_pickup(body)

func _on_area_3d_area_entered(_area: Area3D):
	pass
