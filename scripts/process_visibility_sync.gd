extends Node

@onready var parent: Node = get_parent()

func _process(_delta) -> void:
	var parent_can_process = parent.can_process()
	var parent_is_visible = parent.is_visible()
	if parent_can_process != parent_is_visible:
		parent.set_visible(parent_can_process)
