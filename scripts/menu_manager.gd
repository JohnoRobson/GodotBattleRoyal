class_name MenuManager
extends Node

signal start_game_button_pressed(game_type: World.GameTypes)
signal restart_game_button_pressed()
signal return_to_title_button_pressed()

var menus: Array[Menu] = []

func _ready():
	open_menu($TitleMenu)

func clear_menus():
	menus.clear()
	$TransparentOverlay.hide()
	handle_menu_visibility()

func close_menu():
	menus.pop_front()
	if menus.is_empty():
		$TransparentOverlay.hide()
	handle_menu_visibility()

func open_menu(menu:Menu):
	menus.push_front(menu)
	handle_menu_visibility()

func handle_menu_visibility():
	for menu:Control in get_children():
		if not menus.is_empty() and menus.front().name == menu.name:
			menu.show()
		elif menu.name != 'TransparentOverlay':
			menu.hide()

func open_death_menu():
	clear_menus()
	$TransparentOverlay.show()
	open_menu($DeathMenu)

func open_win_menu(winner: Team):
	clear_menus()
	$WinMenu.set_winner(winner)
	open_menu($WinMenu)

func open_pause_menu():
	clear_menus()
	$TransparentOverlay.show()
	open_menu($PauseMenu)

func _on_start_game_button_pressed(game_type: World.GameTypes):
	clear_menus()
	open_menu($LoadingScreen)
	start_game_button_pressed.emit(game_type)

func _on_return_to_title_button_pressed():
	clear_menus()
	open_menu($TitleMenu)
	return_to_title_button_pressed.emit()

func _on_settings_button_pressed():
	open_menu($SettingsMenu)

func _on_back_button_pressed():
	close_menu()

func _on_restart_game_button_pressed():
	clear_menus()
	open_menu($LoadingScreen)
	restart_game_button_pressed.emit()
