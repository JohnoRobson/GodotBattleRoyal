class_name Reporter
extends Node
## Returns a Dictionary of values from its parent node's variables whose names match its selected_variables values
## Also handles transforming certain objects into informative string values, such as a Health node into 90/100
## if 90 is the current health and 100 is the max health.

@export var selected_variables: Array[String] = []

## Asserts that the selected_variable values match variables in the parent node
func _validate_selected_variables(list: Array[Dictionary]) -> void:
	var list_var_names = list.map(func(a): return a["name"])
	assert(selected_variables.all(func(a): return list_var_names.has(a)))

## Returns a Dictionary of variable names from the parent node
func _get_parent_variables() -> Array[Dictionary]:
	var list = get_parent().get_property_list()
	list = list.filter(func(a: Dictionary): return a["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE == PROPERTY_USAGE_SCRIPT_VARIABLE)
	return list

## Returns a Dictionary of variable names and values from the parent node whose names are in selected_variables
func get_report() -> Dictionary:
	var list = _get_parent_variables()
	_validate_selected_variables(list)
	var new_list = {}
	for entry in list:
		var entry_name = entry["name"]
		if selected_variables.has(entry_name):
			new_list[entry_name] = _get_value_for_node(get_parent().get(entry_name))
	
	return new_list

# Converts a variant into a string, formatted where appropriate
func _get_value_for_node(variant) -> String:
	if variant == null:
		return ""
	if variant is Health:
		return "%s/%s" % [(variant as Health).current_health, (variant as Health).max_health]
	if variant is GameItem:
		return (variant as GameItem).item_name
	if variant is AiActorController:
		return "State: %s" % [(variant as AiActorController).state_machine.current_state.get_name()]
	if variant is int:
		return str(variant)
	if variant is float:
		return "%0.2f" % variant
	if variant is Action:
		return Action.Name.keys()[(variant as Action).action_name]
	
	return variant.to_string()
