class_name ActionSystem
extends Node

var action_stacks: Array[ActionStack] = []
var world: World
var frame_count: int = 0
@export var effect_manager: EffectManager

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for action_stack in action_stacks:
		action_stack.perform(delta)
	
	action_stacks = action_stacks.filter(func(a): return !a.stack_is_completed())
	frame_count += 1

func action_triggered(action: Action, game_item: GameItem):
	print("action triggered on frame %s" % frame_count)
	var duplicated_action = action.duplicate(true)
	var action_stack = ActionStack.new()
	action_stack.game_item = game_item
	action_stack.uncompleted_top_level_actions.append(duplicated_action)
	action_stacks.append(action_stack)
	_add_world_reference_to_action_stack(action_stack)

func _add_world_reference_to_action_stack(action_stack: ActionStack):
	for action in action_stack.uncompleted_top_level_actions:
		_add_world_reference_to_action(action)

# TARGETEDACTIONS DON'T GET A WORLD REFERENCE RIGHT NOW!
func _add_world_reference_to_action(action: Action):
	action.world = world
	if action is ActionRaycast:
		action.on_raycast.connect(effect_manager._on_actor_shoot) # terrible
	for child_action in action.actions:
		if child_action.world == null:
			_add_world_reference_to_action(child_action)
