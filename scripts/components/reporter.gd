class_name Reporter extends Node

@export var _selected_variables: Array[String] = []

func _validate_selected_variables(list: Array[Dictionary]) -> void:
	var list_var_names = list.map(func(a): return a["name"])
	assert(_selected_variables.all(func(a): return list_var_names.has(a)))

## Returns a Dictionary of names and values of usful information from the parent node
func _get_parent_variables() -> Array[Dictionary]:
	var list = get_parent().get_property_list()
	list = list.filter(func(a: Dictionary): return a["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE == PROPERTY_USAGE_SCRIPT_VARIABLE)
	return list

func get_report() -> Dictionary:
	var list = _get_parent_variables()
	_validate_selected_variables(list)
	var new_list = {}
	for entry in list:
		var name = entry["name"]
		if _selected_variables.has(name):
			new_list[name] = _get_value_for_node(get_parent().get(name))
		
	return new_list

func _get_value_for_node(variant):
	if variant == null:
		return variant
	if variant is Health:
		return "%s/%s" % [(variant as Health).current_health, (variant as Health).max_health]
	if variant is GameItem:
		return (variant as GameItem).item_name
	if variant is AiActorController:
		return "State: %s" % [(variant as AiActorController).state_machine.current_state.get_name()]
	if variant is int:
		return variant
	if variant is float:
		return "%0.2f" % variant
	
	return variant.to_string()
