class_name ActionSystem
extends Node

var action_stacks: Array[ActionStack] = []
var world: World
var frame_count: int = 0
@export var effect_manager: EffectManager

func _process(delta):
	for action_stack in action_stacks:
		action_stack.perform(delta)
	
	action_stacks = action_stacks.filter(func(a): return !a.stack_is_completed())
	frame_count += 1

func action_triggered(action: Action, game_item: GameItem):
	print("action triggered at frame %s" % frame_count)
	var duplicated_action = action.duplicate(true)
	var action_stack = ActionStack.new(game_item, self, world, _add_connections_to_action)
	action_stack.uncompleted_top_level_actions.append(duplicated_action)
	action_stacks.append(action_stack)

# TARGETEDACTIONS DON'T GET A WORLD REFERENCE RIGHT NOW!
func _add_connections_to_action(action: Action):
	if action is ActionRaycast:
		action.on_raycast.connect(effect_manager._on_actor_shoot) # terrible
	for child_action in action.actions:
		_add_connections_to_action(child_action)
