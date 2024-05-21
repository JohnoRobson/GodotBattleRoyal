class_name GameSceneRoot extends Node

func _process(_delta):
	if Input.is_action_just_pressed("toggle_menu"):
		if $GameScenes.get_child_count() >= 1:
			toggle_pause_screen()
		else:
			get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# We can add on-close behaviour here - MW 2024-05-15
		get_tree().quit()

# Load a new game scene, hide the UI, and unpause
func start_game_scene(new_game_scene:PackedScene):
	var new_instantiated_game_scene = new_game_scene.instantiate()
	new_instantiated_game_scene.game_lost.connect(_on_game_scene_game_lost)
	new_instantiated_game_scene.game_won.connect(_on_game_scene_game_won)
	$GameScenes.add_child(new_instantiated_game_scene)
	$ScreenManager.clear_screens()
	get_tree().paused = false

# Clear all current game scenes from the game scene root
func clear_game_scenes():
	var game_scenes:Node = $GameScenes
	for game_scene in game_scenes.get_children():
		game_scenes.remove_child(game_scene)
		game_scene.queue_free()

func toggle_pause_screen():
	var currently_paused = get_tree().paused
	if not currently_paused:
		$ScreenManager.open_pause_screen()
		get_tree().paused = true
	else:
		$ScreenManager.close_screen()
		get_tree().paused = false

func _on_start_game_pressed():
	clear_game_scenes()
	start_game_scene.call_deferred(load("res://scenes/scene.tscn"))

func _on_game_scene_game_lost():
	clear_game_scenes()
	$ScreenManager.open_death_screen()
	get_tree().paused = true

func _on_game_scene_game_won():
	clear_game_scenes()
	$ScreenManager.open_win_screen()
	get_tree().paused = true

func _on_return_to_title_pressed():
	clear_game_scenes()
	$ScreenManager.open_title_screen()
	get_tree().paused = true

func _on_settings_pressed():
	$ScreenManager.open_settings_screen()
	get_tree().paused = true

func _on_back_pressed():
	$ScreenManager.close_screen()
