extends SplitContainer

func _ready():
	for child in get_children():
		child.process_mode = Node.PROCESS_MODE_DISABLED

func _input(_event):
	if Input.is_action_just_pressed("debug_menu"):
		visible = !visible
		for child in get_children():
			if visible:
				child.process_mode = Node.PROCESS_MODE_INHERIT
			else:
				child.process_mode = Node.PROCESS_MODE_DISABLED 
