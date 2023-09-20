extends Node3D

class_name World

@onready var player_actors: Array[Actor] = []
@onready var ai_actors: Array[Actor] = []
@onready var items: Array[GameItem] = []
@onready var weapons: Array[GameItem] = []

@export var effect_manager: EffectManager

@export var nav_region: NavigationRegion3D

@export var action_system: ActionSystem

enum Weapons {SMG, SHOTGUN, SNIPER}

func _ready():
	action_system.world = self
	spawn_player(Vector2(0,5))
	#spawn_ai(Vector2(-10,0))
	#spawn_ai(Vector2(-10,5))
	#spawn_ai(Vector2(30,0))
	spawn_weapon(Vector2(5,5), Weapons.SMG)
	spawn_weapon(Vector2(-15,5), Weapons.SHOTGUN)
	spawn_weapon(Vector2(25,-5), Weapons.SNIPER)
	items.append_array(get_tree().get_nodes_in_group("items"))
	for item in items:
		item.action_triggered.connect(action_system.action_triggered)

func _process(_delta):
	pass

func _physics_process(_delta):
	pass

# Common actor initializations (player and AI)
func _init_actor(actor: Actor, spawn_position: Vector2):
	# TODO: fix incorrect spawn location bug when spawning at (0,0)
	actor.actor_killed.connect(_on_actor_killed)
	add_child(actor)
	actor.set_global_position(Vector3(spawn_position.x, 0.0, spawn_position.y))
	actor.weapon_inventory.return_item_to_world.connect(_return_item_to_world)
	actor.weapon_inventory.inventory_data = InventoryData.new()
	for i in 3:
		actor.weapon_inventory.inventory_data._slots.append(InventorySlotData.new())

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

	actor.health.take_damage(80)
	
	var inventory_ui: InventoryUI = actor.get_node("HUD/Inventory")

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
	controller.state_machine = StateMachine.new(FindEnemyState.new(), controller)

# Spawn SMG
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
	add_child(weapon)
	weapon.set_global_position(Vector3(spawn_position.x, 5.0, spawn_position.y))
	weapon.set_global_rotation_degrees(Vector3(0, 90, 0))
	weapons.append(weapon)
	return weapon

func _on_actor_killed(actor: Actor):
	player_actors.erase(actor)
	ai_actors.erase(actor)
	
	# check for win condition
	if player_actors.size() + ai_actors.size() == 1:
		get_tree().change_scene_to_file("res://scenes/win_screen.tscn")

func get_closest_actor(from_position: Vector3, ignore: Actor = null) -> Actor:
	var actors = player_actors + ai_actors # Apparently you can concatenate arrays like this - MW 2023-05-15

	if ignore != null:
		actors.erase(ignore)

	actors.sort_custom(func(a, b): return from_position.distance_to(a.global_transform.origin) < from_position.distance_to(b.global_transform.origin))

	# weird ternary
	return actors.front() if !actors.is_empty() else null

func get_closest_available_health(from_position: Vector3) -> GameItem:
	var pickups = []
	pickups.append_array(items)

	# Filter returns the filtered array, but sort is in-place
	pickups = pickups.filter(func(a): return a != null and !a.is_held)
	pickups = pickups.filter(func(a): return a.item_name == "Medkit")
	pickups.sort_custom(func(a, b): return from_position.distance_to(a.global_transform.origin) < from_position.distance_to(b.global_transform.origin))

	return pickups.front() if !pickups.is_empty() else null

func get_closest_available_weapon(from_position: Vector3) -> Weapon:
	var weapon_array = []
	weapon_array.append_array(weapons)

	weapon_array.sort_custom(func(a, b): return from_position.distance_to(a.global_transform.origin) < from_position.distance_to(b.global_transform.origin))
	weapon_array = weapon_array.filter(func(a): return !a.is_held)

	return weapon_array.front() if !weapon_array.is_empty() else null

func _on_player_killed(_player: Actor):
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")

func _return_item_to_world(item: GameItem, global_position_to_place_item: Vector3, global_rotation_to_place_item: Vector3):
	if item.get_parent() != null:
		item.get_parent().remove_child(item)
	add_child(item)
	item.global_position = global_position_to_place_item
	item.rotation = global_rotation_to_place_item

func get_actors_and_gameitems_in_area(target_position: Vector3, distance: float) -> Array:
	var things = player_actors + ai_actors + items

	return things.filter(func(a):return a != null).filter(func(a): return a.is_inside_tree()).filter(func(a): return target_position.distance_to(a.global_transform.origin) <= distance)
