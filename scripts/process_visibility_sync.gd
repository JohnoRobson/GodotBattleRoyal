extends Node

func _process(delta):
	var player_hud = get_parent()
	var player_hud_can_process = player_hud.can_process()
	if player_hud_can_process != player_hud.is_visible():
		player_hud.set_visible(player_hud_can_process)
