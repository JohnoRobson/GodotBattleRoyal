extends MeshInstance3D

class_name BulletEffect

@export var start: Vector3 = Vector3.ZERO
@export var end: Vector3 = Vector3(0.0,0.0,-50.0)
@export_range(0.0, 10.0, 0.1) var lifetime_seconds = 0.5

var starting_width = 0.05
var width = starting_width
var dist = 0.0

func _ready():
	dist = start.distance_to(end) / 2
	mesh.size = Vector3(starting_width, starting_width, dist)
	#look_at(end, Vector3.UP)

	var q = (end - start).normalized() / 2


	look_at_from_position(start + q, end)
	#translate(Vector3(0.0, 0.0, -dist / 2))
	#self.transform.basis.z -= dist
	#translate_object_local(Vector3.FORWARD * dist)
	#basis.
	#translation += spatial.global_transform.basis.z * dist

func _process(delta):
	lifetime_seconds -= delta
	width -= delta * starting_width
	mesh.size = Vector3(width, width, start.distance_to(end))
	if lifetime_seconds <= 0.0:
		queue_free()
