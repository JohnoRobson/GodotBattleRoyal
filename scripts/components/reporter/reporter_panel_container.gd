class_name ReporterPanelContainer
extends PanelContainer
## Holds ReporterContainers within itself to align them vertically
## Handles turning the name of a node and the Dictionary returned by its Reporter into a visible ReporterContainer

var reporter_container = preload("res://scenes/components/reporter/reporter_container.tscn")
var last_added_container: ReporterContainer = null

func add_panel(title: String, dict: Dictionary) -> void:
	var new_reporter_container: ReporterContainer = reporter_container.instantiate()
	
	if last_added_container == null:
		add_child(new_reporter_container)
		new_reporter_container.set_text(title, dict)
		last_added_container = new_reporter_container
	else:
		# in order for the VBoxContainer's vertical alignment to work,
		# each sucessive container must be a child of the previous one
		last_added_container.add_child(new_reporter_container)
		new_reporter_container.set_text(title, dict)
		last_added_container = new_reporter_container
