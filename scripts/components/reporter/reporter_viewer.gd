class_name ReporterViewer
extends Control

@export var nodes_whose_children_to_check: Array[Node]
var _reporter_panel_containers: Array[ReporterPanelContainer] = []

func _process(_delta: float) -> void:
	# remove the panels from last tick because they may have moved or their reporters may have been destroyed
	# swap this out for panel reuse if this is too much of a perfomance hit
	for reporter_panel_container in _reporter_panel_containers:
		reporter_panel_container.queue_free()
	_reporter_panel_containers.clear()
	
	# we need to sort the nodes so that their reporter panels are instanciated in order of their distance from the camera
	var sort_by_distance = func(a, b):
		var camera_position = get_viewport().get_camera_3d().global_position
		var a_distance = camera_position.distance_to(a.global_position)
		var b_distance = camera_position.distance_to(b.global_position)
		return a_distance > b_distance
	
	var nodes_to_sort: Array[Node] = get_top_level_nodes_with_reporters_for_multiple_nodes(nodes_whose_children_to_check)
	nodes_to_sort.sort_custom(sort_by_distance)
	
	# instantiate the panels
	for node in nodes_to_sort:
		var pos_2d = get_viewport().get_camera_3d().unproject_position(node.global_position)
		var reporter_panel_container = preload("res://scenes/components/reporter/reporter_panel_container.tscn").instantiate()
		add_child(reporter_panel_container)
		reporter_panel_container.position = pos_2d
		reporter_panel_container.add_panel(_get_node_name(node), get_report(node))
		_reporter_panel_containers.append(reporter_panel_container)
		
		for child_node in get_all_nodes_with_reporters_within_node(node):
			reporter_panel_container.add_panel(_get_node_name(child_node), get_report(child_node))

func _get_node_name(node) -> String:
		var node_name = node.name
		if node is GameItem:
			node_name = node.item_name
		return node_name

func get_top_level_nodes_with_reporters_for_multiple_nodes(nodes_to_check: Array[Node]) -> Array[Node]:
	var array: Array[Node] = []
	for node in nodes_to_check:
		array.append_array(get_top_level_nodes_with_reporters(node))
	return array

func get_top_level_nodes_with_reporters(node_to_check: Node) -> Array[Node]:
	# get siblings
	var sibling_nodes: Array[Node] = node_to_check.get_children()
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
	RoyalLogger.error("Reporter not found in %s" % [ node ])
	return {}

func _has_reporter(node: Node) -> bool:
	for child in node.get_children():
		if child is Reporter:
			return true
	return false
