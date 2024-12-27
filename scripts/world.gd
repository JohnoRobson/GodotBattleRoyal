class_name World extends Node3D

@onready var player_actors: Array[Actor] = []
@onready var ai_actors: Array[Actor] = []
@onready var world_camera: Camera3D = get_node("Camera3D")

@onready var actor_container: Node = get_node("ActorContainer")
@onready var item_container: Node = get_node("ItemContainer")

@export var effect_manager: EffectManager

@export var nav_region: NavigationRegion3D

@export var action_system: ActionSystem

@export var camera_zoom_speed: float = 0.27
@export var camera_max_distance: float = 30
@export var camera_min_distance: float = 5

enum Weapons {SMG, SHOTGUN, SNIPER}
enum GameTypes {AI, SANDBOX, CLASSIC}

signal game_lost
signal game_won
signal game_loaded

signal pause_button_pressed

func _ready():
	action_system.world = self
	world_camera.make_current()
	Logger.logging_level = Logger.LoggingLevel.TRACE

func _process(_delta):
	if Input.is_action_pressed("zoom_out"):
		move_camera(camera_zoom_speed)
	if Input.is_action_pressed("zoom_in"):
		move_camera(-camera_zoom_speed)

func _physics_process(_delta):
	pass

# Common actor initializations (player and AI)
func _init_actor(actor: Actor, spawn_position: Vector2):
	# TODO: fix incorrect spawn location bug when spawning at (0,0)
	actor.actor_killed.connect(_on_actor_killed)
	
	actor_container.add_child(actor)
	actor.set_global_position(Vector3(spawn_position.x, 0.0, spawn_position.y))
	actor.weapon_inventory.return_item_to_world.connect(return_item_to_world)
	actor.weapon_inventory.inventory_data = InventoryData.new()
	for i in 3:
		actor.weapon_inventory.inventory_data._slots.append(InventorySlotData.new())

# To be run after a game setup function has been called
func conclude_loading():

	# move this somewhere else
	for item in get_tree().get_nodes_in_group("items"):
		item.action_triggered.connect(action_system.action_triggered)

	game_loaded.emit()

func move_camera(distance):
	var camera: Camera3D = get_viewport().get_camera_3d()
	var forward_vector = -camera.transform.basis.z
	var new_position = camera.transform.origin + forward_vector * distance

	var distance_from_origin = new_position.length()
	if distance_from_origin > camera_max_distance:
		var excess_distance = camera_max_distance - distance_from_origin
		var adjusted_distance = distance - excess_distance
		new_position = camera.transform.origin + forward_vector * adjusted_distance
	if distance_from_origin < camera_min_distance:
		var excess_distance = distance_from_origin - camera_min_distance
		var adjusted_distance = distance + excess_distance
		new_position = camera.transform.origin + forward_vector * adjusted_distance

	camera.transform.origin = new_position

# Spawn player actor and create new player controller
func spawn_player(spawn_position: Vector2):
	var actor: Actor = preload("res://scenes/player_actor.tscn").instantiate()
	_init_actor(actor, spawn_position)
	player_actors.append(actor)
	actor.actor_killed.connect(_on_player_killed)

	# Add player controller
	var controller = Node3D.new()
	var controller_script = preload("res://scripts/player_actor_controller.gd")
	controller.name = "PlayerActorController"
	controller.set_script(controller_script)
	actor.controller = controller
	actor.add_child(controller)
	actor.make_camera_current()
	
	var inventory_ui: InventoryUI = actor.get_node("PlayerHud/Inventory")

	var inventory: Inventory = actor.get_node("WeaponInventory")
	inventory_ui.selected_slot_scrolled_up.connect(inventory.selected_slot_scrolled_up)
	inventory_ui.selected_slot_scrolled_down.connect(inventory.selected_slot_scrolled_down)

	inventory.emit_updates() # hack to get the ui to update on game start

# Spawn AI actor and configure existing AI controller
func spawn_ai(spawn_position: Vector2):
	var actor: Actor = preload("res://scenes/ai_actor.tscn").instantiate()
	_init_actor(actor, spawn_position)
	ai_actors.append(actor)

	# Configure AI controller
	var controller: AiActorController = actor.controller
	controller.actor = actor
	controller.world = self
	controller.world_navmesh = nav_region
	controller.state_machine = StateMachine.new(DecisionMakingState.new(), controller)

func spawn_weapon(spawn_position: Vector2, weapon_type: Weapons) -> Weapon:
	var weapon: Weapon
	match weapon_type:
		Weapons.SHOTGUN:
			weapon = preload("res://scenes/weapons/shotgun.tscn").instantiate()
		Weapons.SMG:
			weapon = preload("res://scenes/weapons/smg.tscn").instantiate()
		Weapons.SNIPER:
			weapon = preload("res://scenes/weapons/sniper_rifle.tscn").instantiate()
		_:
			return

	weapon.on_firing.connect(effect_manager._on_actor_shoot)
	item_container.add_child(weapon)
	weapon.set_global_position(Vector3(spawn_position.x, 5.0, spawn_position.y))
	weapon.set_global_rotation_degrees(Vector3(0, 90, 0))
	return weapon

func _on_actor_killed(actor: Actor):
	player_actors.erase(actor)
	ai_actors.erase(actor)
	
	var current_camera = get_viewport().get_camera_3d()
	if actor == current_camera.get_parent():
		make_random_ai_camera_current()

	# check for win condition
	if get_win_condition_satisfied():
		action_system.shut_down()
		game_won.emit()

func get_win_condition_satisfied() -> bool:
	if player_actors.size() >= 1 and ai_actors.size() == 0:
		return true
	return false

func get_closest_actor(from_position: Vector3, ignore: Actor = null) -> Actor:
	var actors = player_actors + ai_actors # Apparently you can concatenate arrays like this - MW 2023-05-15

	if ignore != null:
		actors.erase(ignore)

	actors.sort_custom(func(a, b): return from_position.distance_to(a.global_transform.origin) < from_position.distance_to(b.global_transform.origin))

	# weird ternary
	var closest_actor: Actor = actors.front() if !actors.is_empty() else null
	#print("closest actor: %s, ignore: %s" % [closest_actor, ignore])
	return closest_actor

func get_random_ai_actor() -> Actor:
	if ai_actors.is_empty():
		return null
	return ai_actors.pick_random()

func get_closest_available_health(from_position: Vector3) -> GameItem:
	var pickups = []
	pickups.append_array(get_tree().get_nodes_in_group("healing"))

	# Filter returns the filtered array, but sort is in-place
	pickups = pickups.filter(func(a): return a != null and !a.is_held and a.can_be_used)
	#pickups = pickups.filter(func(a): return a.item_name == "Medkit")
	pickups.sort_custom(func(a, b): return from_position.distance_to(a.global_transform.origin) < from_position.distance_to(b.global_transform.origin))

	return pickups.front() if !pickups.is_empty() else null

func get_closest_available_weapon(from_position: Vector3) -> GameItem:
	var weapon_array = []
	weapon_array.append_array(get_tree().get_nodes_in_group("weapons"))

	weapon_array.sort_custom(func(a, b): return from_position.distance_to(a.global_transform.origin) < from_position.distance_to(b.global_transform.origin))
	weapon_array = weapon_array.filter(func(a): return !a.is_held && a.can_be_used)

	return weapon_array.front() if !weapon_array.is_empty() else null

func get_closest_item_with_traits(from_position: Vector3, item_traits: Array[GameItem.ItemTrait]) -> GameItem:
	var items = []
	
	items.append_array(get_tree().get_nodes_in_group("healing"))
	items.append_array(get_tree().get_nodes_in_group("weapons"))
	items = items.filter(func(a): return a != null and !a.is_held and a.can_be_used)
	items = items.filter(func(a): return item_traits.all(func(b): return b in a.traits))
	items.sort_custom(func(a, b): return from_position.distance_to(a.global_transform.origin) < from_position.distance_to(b.global_transform.origin))
	
	return items.front() if !items.is_empty() else null

# this is not good
func get_closest_healing_aura(from_position: Vector3) -> GameItem:
	var items = []
	
	items.append_array(get_tree().get_nodes_in_group("aoe"))
	items = items.filter(func(a): return a != null and !a.is_held and !a.can_be_used)
	items = items.filter(func(a): return a.traits.has(GameItem.ItemTrait.HEALING))
	items.sort_custom(func(a, b): return from_position.distance_to(a.global_transform.origin) < from_position.distance_to(b.global_transform.origin))
	
	return items.front() if !items.is_empty() else null

func make_random_ai_camera_current() -> void:
	var ai_actor = get_random_ai_actor()
	if ai_actor != null:
		ai_actor.make_camera_current()
	else: # on no more ai actors, set camera to world
		world_camera.make_current()

func _on_player_killed(_player: Actor):
	make_random_ai_camera_current()
	game_lost.emit()

func return_item_to_world(item: GameItem, global_position_to_place_item: Vector3, global_rotation_to_place_item: Vector3):
	if item.get_parent() != null:
		item.get_parent().remove_child(item)
	item_container.add_child(item)
	item.global_position = global_position_to_place_item
	item.rotation = global_rotation_to_place_item

func get_actors_and_gameitems_in_area(target_position: Vector3, distance: float) -> Array:
	var things = player_actors + ai_actors + get_tree().get_nodes_in_group("items")

	return things.filter(func(a):return a != null).filter(func(a): return a.is_inside_tree()).filter(func(a): return target_position.distance_to(a.global_transform.origin) <= distance)

func setup_game(game_type: GameTypes):
	spawn_weapon(Vector2(5,5), Weapons.SMG)
	spawn_weapon(Vector2(-15,5), Weapons.SHOTGUN)
	spawn_weapon(Vector2(25,-5), Weapons.SNIPER)
	match game_type:
		GameTypes.AI:
			spawn_ai(Vector2(-10,0))
			spawn_ai(Vector2(-10,5))
			spawn_ai(Vector2(30,0))
			make_random_ai_camera_current()
		GameTypes.SANDBOX:
			spawn_player(Vector2(0,5))
		GameTypes.CLASSIC, _:
			spawn_player(Vector2(0,5))
			spawn_ai(Vector2(-10,0))
			spawn_ai(Vector2(-10,5))
			spawn_ai(Vector2(30,0))
	conclude_loading()

func _on_pause_button_pressed():
	pause_button_pressed.emit()
