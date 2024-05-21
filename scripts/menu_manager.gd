class_name MenuManager extends Node

var menus: Array[Control] = []

func _ready():
	open_menu($TitleMenu)

func open_title_menu():
	clear_menus()
	open_menu($TitleMenu)

func open_death_menu():
	clear_menus()
	open_menu($DeathMenu)

func open_win_menu():
	clear_menus()
	open_menu($WinMenu)

func open_pause_menu():
	clear_menus()
	open_menu($PauseMenu)

func open_settings_menu():
	open_menu($SettingsMenu)

func clear_menus():
	menus.clear()
	handle_menu_visibility()

func close_menu():
	menus.pop_front()
	handle_menu_visibility()

func open_menu(menu:Menu):
	menus.push_front(menu)
	handle_menu_visibility()

func handle_menu_visibility():
	for menu:Control in get_children():
		if not menus.is_empty() and menus.front().name == menu.name:
			menu.show()
		else:
			menu.hide()
