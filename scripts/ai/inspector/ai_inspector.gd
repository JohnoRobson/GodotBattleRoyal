class_name AiInspector extends Control

@export var world: World
@onready var panel: Panel = get_node("Panel")
@onready var label: Label = get_node("Panel/Label")

const CAMERA_RAYCAST_COLLISION_MASK = 0b0111

var _selected_ai: AiActorController

func _process(_delta: float):
	if _selected_ai and is_instance_valid(_selected_ai):
		panel.show()
		var text = _selected_ai.name + "\n"
		
		for entry: StateEvaluation in _selected_ai.state_machine.previous_state_evaluations.get_last_evaluation():
			text += "%s: %0.2f\n" % [entry.state.get_name(), entry.score]
		
		label.text = text
	else:
		panel.hide()

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		_selected_ai = get_ai_clicked_on()

func get_ai_clicked_on() -> AiActorController:
	var space_state = world.get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 2000
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, CAMERA_RAYCAST_COLLISION_MASK)
	var result = space_state.intersect_ray(query)
	
	if result:
		var target = result.collider
		if target != null and target is Actor:
			if (target as Actor).controller is AiActorController:
				return (target as Actor).controller
	
	return null
