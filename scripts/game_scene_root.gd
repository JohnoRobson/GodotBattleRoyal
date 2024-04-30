class_name GameSceneRoot extends Node

func _ready():
	open_title_screen()

# Load a new game scene, hide the UI, and unpause
func start_game_scene(new_game_scene:PackedScene):
	var new_instantiated_game_scene = new_game_scene.instantiate()
	new_instantiated_game_scene.game_lost.connect(_on_game_scene_game_lost)
	new_instantiated_game_scene.game_won.connect(_on_game_scene_game_won)
	$GameScenes.add_child(new_instantiated_game_scene)
	$TitleScreen.hide()
	$WinScreen.hide()
	$LostScreen.hide()
	get_tree().paused = false

# Clear all current game scenes from the game scene root
func clear_game_scenes():
	var game_scenes:Node = $GameScenes
	for game_scene in game_scenes.get_children():
		game_scenes.remove_child(game_scene)
		game_scene.queue_free()

# Clear the game and open the title screen
func open_title_screen():
	clear_game_scenes()
	$WinScreen.hide()
	$LostScreen.hide()
	$TitleScreen.show()
	get_tree().paused = true

func _on_start_game_pressed():
	clear_game_scenes()
	start_game_scene.call_deferred(load("res://scenes/scene.tscn"))

func _on_game_scene_game_lost():
	clear_game_scenes()
	$LostScreen.show()
	get_tree().paused = true

func _on_game_scene_game_won():
	clear_game_scenes()
	$WinScreen.show()
	get_tree().paused = true

func _on_return_to_title_pressed():
	open_title_screen()
