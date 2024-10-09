class_name ReporterManager extends Node

# actions that I would like to use this for
# 1. show me all top-level nodes with reporters (Actors, GameItems on the ground) so that I can pick one to inspect further
# 2. show me all the nodes with reporters within a top-level node, such as the reporters within an Actor so that I can get information on one part of it
# 3. get the report from a specific node

func get_top_level_nodes_with_reporters() -> Array[Node]:
	# get siblings
	var sibling_nodes: Array[Node] = get_parent().get_children()
	sibling_nodes.erase(self)
	
	var nodes_with_reporters: Array[Node] = []
	
	for node: Node in sibling_nodes:
		if _has_reporter(node):
			nodes_with_reporters.append(node)
	
	return nodes_with_reporters

func get_all_nodes_with_reporters_within_node(scene: Node) -> Array[Node]:
	var nodes_with_reporters: Array[Node] = []
	
	var nodes_to_check: Array[Node] = []
	nodes_to_check.append_array(scene.get_children())
	
	for node: Node in nodes_to_check:
		nodes_to_check.append_array(node.get_children())
		
		if _has_reporter(node):
			nodes_with_reporters.append(node)
	
	return nodes_with_reporters

func get_report(node: Node) -> Dictionary:
	for child in node.get_children():
		if child is Reporter:
			return (child as Reporter).get_report()
	Logger.error("Reporter not found in %s" % [ node ])
	return {}

func _has_reporter(node: Node) -> bool:
	for child in node.get_children():
		if child is Reporter:
			return true
	return false
	
