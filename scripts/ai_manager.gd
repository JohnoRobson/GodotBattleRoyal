extends Node3D

@export var world_navmesh: NavigationRegion3D
@export var ai_actor: AiActor
@export var world: World

var ai_controller: AiActorController

func _ready():
	ai_controller = ai_actor.controller

func _physics_process(delta):
	if !world.player_actors.is_empty() && ai_actor != null:
		var player_actor = world.player_actors[0]
		var player_pos = player_actor.global_transform.origin
		ai_actor.nav_agent.target_position = player_pos
		
		#move
		var current_location = ai_actor.global_transform.origin
		var next_location = ai_actor.nav_agent.get_next_path_position()
		var dir = (next_location - current_location).normalized()
		ai_controller.set_move_direction(Vector2(dir.x, dir.z))
		
		#aim
		ai_controller.set_aim_position(player_pos + (Vector3.UP * 1.5))
		
		#shoot
		var player_distance: float = player_pos.distance_to(ai_actor.global_transform.origin)
		if player_distance <= 50.0:
			ai_controller.set_is_shooting(true)
		else:
			ai_controller.set_is_shooting(false)
