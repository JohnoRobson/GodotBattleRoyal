class_name ReporterContainer
extends VBoxContainer
## Displays a group of values returned by a Reporter

@onready var _title: Label = $Title
@onready var _label: Label = $Label

func set_text(title: String, dict: Dictionary) -> void:
	_title.text = title
	
	var text: String = ""
	for key in dict.keys():
		text = text + "%s:%s\n" % [key, dict[key]]
	text.trim_suffix("\n")
	_label.text = text
