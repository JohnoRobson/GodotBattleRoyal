class_name WinMenu
extends Menu

func set_winner(winner: Team) -> void:
	$Title.text = "%s Wins!" % winner.display_name
