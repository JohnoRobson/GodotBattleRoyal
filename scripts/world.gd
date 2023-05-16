extends Node3D

class_name World

@onready var player_actors: Array[Actor] = []
@onready var ai_actors: Array[AiActor] = []
@onready var health_pickups: Array[HealthPickup] = []

@export var effect_manager: EffectManager

@export var nav_region: NavigationRegion3D

func _ready():
	spawn_player(Vector2(0,5))
	spawn_ai(Vector2(-10,0))
	spawn_ai(Vector2(-10,5))
	spawn_ai(Vector2(30,0))
	health_pickups.append_array(get_tree().get_nodes_in_group("health_pickups"))

func _process(_delta):
	pass

func _physics_process(_delta):
	pass

# Common actor initializations (player and AI)
func _init_actor(actor: Actor, spawn_position: Vector2):
	# TODO: fix incorrect spawn location bug when spawning at (0,0)
	actor.shoot.connect(effect_manager._on_actor_shoot)
	actor.actor_killed.connect(_on_actor_killed)
	add_child(actor)
	actor.set_global_position(Vector3(spawn_position.x, 0.0, spawn_position.y))

# Spawn player actor and create new player controller
func spawn_player(spawn_position: Vector2):
	var actor: Actor = preload("res://scenes/player_actor.tscn").instantiate()
	_init_actor(actor, spawn_position)
	player_actors.append(actor)

	# Add player controller
	var controller = Node3D.new()
	var controller_script = preload("res://scripts/player_actor_controller.gd")
	controller.name = "PlayerActorController"
	controller.set_script(controller_script)
	actor.controller = controller
	actor.add_child(controller)

# Spawn AI actor and configure existing AI controller
func spawn_ai(spawn_position: Vector2):
	var actor: AiActor = preload("res://scenes/ai_actor.tscn").instantiate()
	_init_actor(actor, spawn_position)
	ai_actors.append(actor)

	# Configure AI controller
	var controller: AiActorController = actor.controller
	controller.actor = actor
	controller.world = self
	controller.world_navmesh = nav_region
	controller.state_machine = StateMachine.new(FindEnemyState.new(), controller)

func _on_actor_killed(actor: Actor):
	player_actors.erase(actor)
	ai_actors.erase(actor)

func get_closest_actor(from_position: Vector3, ignore: Actor = null) -> Actor:
	var actors = player_actors + ai_actors # Apparently you can concatenate arrays like this - MW 2023-05-15

	if ignore != null:
		actors.erase(ignore)

	actors.sort_custom(func(a, b): return from_position.distance_to(a.global_transform.origin) < from_position.distance_to(b.global_transform.origin))

	var closest_actor = null
	if !actors.is_empty():
		closest_actor = actors.front()
	return closest_actor

func get_closest_available_health(from_position: Vector3) -> HealthPickup:
	var pickups = []
	pickups.append_array(health_pickups)

	pickups.sort_custom(func(a, b): return from_position.distance_to(a.global_transform.origin) < from_position.distance_to(b.global_transform.origin))
	pickups.filter(func(a): return a.health_is_available)
	return pickups.front()
