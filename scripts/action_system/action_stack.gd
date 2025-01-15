class_name ActionStack
extends Node

# This represents a tree of actions. Each individual instance of an action tree being performed is represented by an ActionStack.
# The ActionStack handles action tree state along with keeping track of the game item the action is linked to.

var uncompleted_top_level_nodes: Array[ItemNode] = []
var root_game_item: GameItem
var action_system: ActionSystem
var callable_for_actions: Callable
var world: World
var is_canceled: bool

func _init(_root_game_item: GameItem, _action_system: ActionSystem, _world: World, _callable_for_actions: Callable, _first_action: Action):
	root_game_item = _root_game_item
	action_system = _action_system
	world = _world
	callable_for_actions = _callable_for_actions
	var first_node: ItemNode = make_node_from_action(_first_action, root_game_item, null)
	uncompleted_top_level_nodes.append(first_node)
	callable_for_actions.call(_first_action)
	is_canceled = false

func perform(delta: float):
	if uncompleted_top_level_nodes.is_empty():
		return
	var there_are_completable_actions = true
	var uncompleted_node_index = 0
	var current_node: ItemNode = uncompleted_top_level_nodes[uncompleted_node_index]
	
	while there_are_completable_actions and !is_canceled:
		var current_action_is_completed: bool
		
		Logger.trace("performing action %s" % Action.Name.keys()[current_node.action.action_name])
		current_action_is_completed = current_node.action.perform(delta, current_node)
		
		if current_action_is_completed:
			uncompleted_top_level_nodes.remove_at(uncompleted_node_index)

			if current_node.action.has_children() or !current_node.child_nodes.is_empty():
				# add the current_action's children to the actions to complete and set up ItemNodes for them
				# reverse ordered for loop so that the insert puts the new nodes in the order as viewed in the editor
				for i in range(current_node.action.actions.size()-1, -1, -1):
					var new_node: ItemNode = make_node_from_action(current_node.action.actions[i], current_node.game_item, current_node)
					uncompleted_top_level_nodes.insert(uncompleted_node_index, new_node)
				
				for i in range(current_node.child_nodes.size()-1, -1, -1):
					var child_node: ItemNode = current_node.child_nodes[i]
					set_action_keys_for_node(child_node)
					
					callable_for_actions.call(child_node.action)
					uncompleted_top_level_nodes.insert(uncompleted_node_index, child_node)
		else:
			uncompleted_node_index += 1
		if uncompleted_node_index > uncompleted_top_level_nodes.size() - 1:
			there_are_completable_actions = false
		else:
			current_node = uncompleted_top_level_nodes[uncompleted_node_index]

func make_node_from_action(action: Action, game_item: GameItem, parent_node: ItemNode) -> ItemNode:
	var node: ItemNode = ItemNode.new(action, game_item, parent_node)
	set_action_keys_for_node(node)
	if action is ActionCreate:
		callable_for_actions.call(action)
	return node

func set_action_keys_for_node(item_node: ItemNode) -> void:
	item_node.data[Action.Keys.ACTION_SYSTEM] = action_system # change this?
	if !item_node.data.has(Action.Keys.POSITION):
		item_node.data[Action.Keys.POSITION] = item_node.game_item.global_position
	item_node.data[Action.Keys.WORLD] = world # this is a little weird and should probably change, but Actions do need a way to access the world to find Actors/GameItems and do things.

func stack_is_completed() -> bool:
	return uncompleted_top_level_nodes.is_empty()

func cancel_stack() -> void:
	is_canceled = true

# The ActionStack makes a tree of ItemNodes that matches the Action tree. Each action gets an ItemNode to store state in.
# Additionaly, Actions can add new ItemNodes as child nodes or change the fields of the ItemNode that they're linked to,
# For example, ActionReplace makes a new instance of a GameItem and replaces its ItemNode's game_item value with the new object and
# adds the new GameItem's Actions as children to the ItemNode so that they are executed by the current ActionStack. 
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
