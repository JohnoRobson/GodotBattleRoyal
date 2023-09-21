class_name ActionStack
extends Node

@export var uncompleted_top_level_actions: Array[Action] = []
var root_game_item: GameItem
var action_system: ActionSystem
#var stack_action_data: Dictionary = {} # GameItem to Dictionary
var node_dict: Dictionary = {} # Action to ItemNode
var callable_for_actions: Callable
var world: World

func _init(_root_game_item: GameItem, _action_system: ActionSystem, _world: World, _callable_for_actions: Callable):
	root_game_item = _root_game_item
	action_system = _action_system
	world = _world
	callable_for_actions = _callable_for_actions
	#stack_action_data[root_game_item] = {}

func perform(delta: float):
	if uncompleted_top_level_actions.is_empty():
		return
	var there_are_completable_actions = true
	var current_action_index = 0
	var current_action: Action = uncompleted_top_level_actions[current_action_index]

	# if we're on the first loop, we make the root
	if node_dict.is_empty():
		node_dict[current_action] = ItemNode.new(current_action, root_game_item, null)
		set_action_keys_for_node(node_dict[current_action])
		callable_for_actions.call(current_action)
	
	while there_are_completable_actions:
		var current_action_is_completed: bool
		var current_node: ItemNode = node_dict[current_action]
		var current_game_item: GameItem = current_node.game_item
		# if !stack_action_data.has(current_game_item):
		# 	stack_action_data[current_game_item] = {}
		
		current_action_is_completed = current_action.perform(delta, current_node)
		if current_action_is_completed:
			if current_action.has_children():
				# add the current_action's children to the actions to complete and set up ItemNodes for them
				uncompleted_top_level_actions.append_array(current_action.actions)
				#uncompleted_top_level_actions.
				for action in current_action.actions:
					node_dict[action] = ItemNode.new(action, current_node.game_item, current_node)
					set_action_keys_for_node(node_dict[action])

					if action is ActionCreate:
						callable_for_actions.call(action)
			uncompleted_top_level_actions.remove_at(current_action_index)
		else:
			current_action_index += 1
		if current_action_index > uncompleted_top_level_actions.size() - 1:
			there_are_completable_actions = false
			current_action = null
		else:
			current_action = uncompleted_top_level_actions[current_action_index]

func set_action_keys_for_node(item_node: ItemNode) -> void:
	item_node.data[Action.Keys.ACTION_SYSTEM] = action_system # change this?
	item_node.data[Action.Keys.POSITION] = root_game_item.global_position
	item_node.data[Action.Keys.WORLD] = world

func stack_is_completed() -> bool:
	return uncompleted_top_level_actions.is_empty()

class ItemNode:
	var action: Action
	var game_item: GameItem
	var parentNode: ItemNode # is null if we are the root
	var data: Dictionary = {}
	var child_nodes: Array[ItemNode] = []

	func _init(_action: Action, _game_item: GameItem, _parentNode: ItemNode):
		action = _action
		game_item = _game_item
		parentNode = _parentNode
