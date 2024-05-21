class_name ScreenManager extends Node

var screens: Array[Control] = []

func _ready():
	open_screen($TitleScreen)

func open_title_screen():
	clear_screens()
	open_screen($TitleScreen)

func open_death_screen():
	clear_screens()
	open_screen($DeathScreen)

func open_win_screen():
	clear_screens()
	open_screen($WinScreen)

func open_pause_screen():
	clear_screens()
	open_screen($PauseScreen)

func open_settings_screen():
	open_screen($SettingsScreen)

func clear_screens():
	screens.clear()
	handle_screen_visibility()

func close_screen():
	screens.pop_front()
	handle_screen_visibility()

func open_screen(screen:MenuScreen):
	screens.push_front(screen)
	handle_screen_visibility()

func handle_screen_visibility():
	for screen:Control in get_children():
		if not screens.is_empty() and screens.front().name == screen.name:
			screen.show()
		else:
			screen.hide()
