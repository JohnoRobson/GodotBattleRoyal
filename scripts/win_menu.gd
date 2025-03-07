class_name WinMenu extends Menu

func set_winner(winner):
	$Title.text = "Team %s Wins!" % winner.display_name
