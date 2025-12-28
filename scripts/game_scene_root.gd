class_name GameSceneRoot extends Node

# Treat CLASSIC as the default game mode from the perspective of the game scene root
var current_game_type:World.GameTypes  = World.GameTypes.CLASSIC

var world_script = preload("res://scripts/world.gd")

func _process(_delta):
	if Input.is_action_just_pressed("toggle_menu"):
		if $GameScenes.get_child_count() >= 1:
			toggle_pause_menu()
		else:
			get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# We can add on-close behaviour here - MW 2024-05-15
		get_tree().quit()

# Load a new game scene, hide the UI, and unpause
func start_game_scene(new_game_scene:PackedScene, game_type: World.GameTypes):
	var new_instantiated_game_scene = new_game_scene.instantiate()
	new_instantiated_game_scene.game_lost.connect(_on_game_scene_game_lost)
	new_instantiated_game_scene.game_won.connect(_on_game_scene_game_won)
	new_instantiated_game_scene.game_loaded.connect(_on_game_scene_game_loaded)
	new_instantiated_game_scene.pause_button_pressed.connect(_on_game_hud_pause_button_pressed)
	$GameScenes.add_child(new_instantiated_game_scene)
	
	if current_game_type != game_type:
		current_game_type = game_type
	new_instantiated_game_scene.setup_game(game_type)
	
	get_tree().paused = false

# Clear all current game scenes from the game scene root
func clear_game_scenes():
	var game_scenes:Node = $GameScenes
	for game_scene in game_scenes.get_children():
		game_scenes.remove_child(game_scene)
		game_scene.queue_free()

func toggle_pause_menu():
	var currently_paused = get_tree().paused
	if not currently_paused:
		$MenuManager.open_pause_menu()
		get_tree().paused = true
	else:
		$MenuManager.clear_menus()
		get_tree().paused = false

func _on_game_scene_game_lost():
	$MenuManager.open_death_menu()

func _on_game_scene_game_won(winner: Team):
	clear_game_scenes()
	
	$MenuManager.open_win_menu(winner)
	get_tree().paused = true

func _on_game_scene_game_loaded():
	$MenuManager.clear_menus()

func _on_start_game_button_pressed(game_type: World.GameTypes):
	clear_game_scenes()
	start_game_scene.call_deferred(load("res://scenes/scene.tscn"), game_type)

func _on_restart_game_button_pressed():
	clear_game_scenes()
	start_game_scene.call_deferred(load("res://scenes/scene.tscn"), current_game_type)

func _on_return_to_title_button_pressed():
	clear_game_scenes()
	get_tree().paused = true

func _on_close_button_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _on_resume_button_pressed():
	toggle_pause_menu()

func _on_game_hud_pause_button_pressed():
	toggle_pause_menu()
