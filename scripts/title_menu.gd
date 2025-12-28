class_name TitleMenu
extends Menu

func _ready() -> void:
	var start_classic_button:Button = self.get_node("Start Classic Button")
	if start_classic_button != null:
		start_classic_button.pressed.connect(_on_start_button_pressed.bind(World.GameTypes.CLASSIC))
	
	var start_ai_only_button:Button = self.get_node("Start AI Only Button")
	if start_ai_only_button != null:
		start_ai_only_button.pressed.connect(_on_start_button_pressed.bind(World.GameTypes.AI))
	
	var start_sandbox_button:Button = self.get_node("Start Sandbox Button")
	if start_sandbox_button != null:
		start_sandbox_button.pressed.connect(_on_start_button_pressed.bind(World.GameTypes.SANDBOX))
