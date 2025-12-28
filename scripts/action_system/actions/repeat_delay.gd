class_name ActionRepeatDelay
extends Action
# Performs its child actions all at once, repeatedly with a delay between each time it activates them all

@export var countdown_in_seconds: float = 1.0
@export var number_of_times_to_activate: int = 1
@export var actions_to_perform: Array[Action] = []

func _init() -> void:
	action_name = self.Name.REPEATDELAY

func perform(_delta: float, _item_node: ActionStack.ItemNode) -> bool:
	var timer_array3: Array[Action] = []

	for i in number_of_times_to_activate:
		var duplicated_actions: Array[Action] = []
		for action in actions_to_perform: # not sure if the duplication step is needed any more
			var dup = action.duplicate(true)
			duplicated_actions.append(dup)
		
		var timer: ActionTimer = ActionTimer.new()
		timer.countdown_in_seconds = countdown_in_seconds * (i) + 1
		timer.actions = duplicated_actions
		
		# do weird array type casting trick
		var timer_array: Array[ActionTimer] = []
		timer_array.append(timer)
		var timer_array2: Array[Action] = []
		timer_array2.assign(timer_array)
		
		timer_array3.append_array(timer_array2)
		
		if i == number_of_times_to_activate - 1:
			# add child actions to final timer
			timer.actions.append_array(actions)
	
	actions = timer_array3
	
	return true
