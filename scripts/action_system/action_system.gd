class_name ActionSystem
extends Node

# This handles performing the actions, along with setting up signals for them.
# Actions should not be called directly, but instead passed to a ActionSystem where it will convert them to an ActionStack and perform them until they are completed.

var action_stacks: Array[ActionStack] = []
var world: World
#var frame_count: int = 0
@export var effect_manager: EffectManager

func _process(delta):
	var uncompleted_action_stacks: Array[ActionStack] = []
	for action_stack in action_stacks:
		action_stack.perform(delta)
		if action_stack.stack_is_completed():
			action_stack.queue_free()
		else:
			uncompleted_action_stacks.append(action_stack)
	
	action_stacks = uncompleted_action_stacks
	#frame_count += 1

func action_triggered(action: Action, game_item: GameItem):
	#print("action triggered at frame %s" % frame_count)
	var duplicated_action = action.duplicate(true)
	var action_stack = ActionStack.new(game_item, self, world, _add_connections_to_action, duplicated_action)
	action_stacks.append(action_stack)

# TARGETEDACTIONS DON'T GET A WORLD REFERENCE RIGHT NOW!
func _add_connections_to_action(action: Action):
	if action is ActionRaycast:
		action.on_raycast.connect(effect_manager._on_actor_shoot) # terrible
	for child_action in action.actions:
		_add_connections_to_action(child_action)
