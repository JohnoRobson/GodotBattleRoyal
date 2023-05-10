extends Node3D

class_name World

@onready var player_actors: Array[Actor] = []
@onready var ai_actors: Array[AiActor] = []
@onready var health_pickups: Array[HealthPickup] = []

@export var effect_manager: EffectManager

@export var nav_region: NavigationRegion3D

func _ready():
	spawn_player(Vector2(0,0))
	spawn_ai(Vector2(-10,0))
	spawn_ai(Vector2(-10,5))
	spawn_ai(Vector2(30,0))
	health_pickups.append_array(get_tree().get_nodes_in_group("health_pickups"))

func _process(delta):
	pass

func _physics_process(delta):
	pass

func spawn_player(position: Vector2):
	var actor: Actor = preload("res://player_actor.tscn").instantiate()
	var controller = Node3D.new()
	controller.name = "PlayerActorController"
	var controller_script = preload("res://scripts/player_actor_controller.gd")
	controller.set_script(controller_script)
	
	actor.controller = controller
	
	actor.add_child(controller)
	player_actors.append(actor)
	actor.global_transform.origin = Vector3(position.x, 0.0, position.y)
	actor.shoot.connect(effect_manager._on_actor_shoot)
	actor.actor_killed.connect(_on_actor_killed)
	add_child(actor)

func spawn_ai(position: Vector2):
	var actor: AiActor = preload("res://ai_actor.tscn").instantiate()
	var controller:AiActorController = actor.controller
	controller.actor = actor
	controller.world = self
	controller.world_navmesh = nav_region
	controller.state_machine = StateMachine.new(FindEnemyState.new(), controller)
	
	ai_actors.append(actor)
	actor.global_transform.origin = Vector3(position.x, 0.0, position.y)
	actor.shoot.connect(effect_manager._on_actor_shoot)
	actor.actor_killed.connect(_on_actor_killed)
	add_child(actor)

func _on_actor_killed(actor: Actor):
	player_actors.erase(actor)
	ai_actors.erase(actor)

func get_closest_actor(position:Vector3, ignore: Actor = null) -> Actor:
	var actors = []
	actors.append_array(player_actors)
	actors.append_array(ai_actors)
	
	if ignore != null:
		actors.erase(ignore)
	
	actors.sort_custom(func(a, b): return position.distance_to(a.global_transform.origin) < position.distance_to(b.global_transform.origin))
	
	return actors.front()

func get_closest_available_health(position:Vector3) -> HealthPickup:
	var pickups = []
	pickups.append_array(health_pickups)
	
	pickups.sort_custom(func(a, b): return position.distance_to(a.global_transform.origin) < position.distance_to(b.global_transform.origin))
	pickups.filter(func(a): return a.health_is_available)
	return pickups.front()
