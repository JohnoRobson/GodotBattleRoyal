class_name ReporterViewer extends Control

@export var reporter_manager: ReporterManager
@export var nodes_whose_children_to_check: Array[Node]
var _reporter_panel_containers: Array[ReporterPanelContainer] = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	# swap this out for panel reuse if this is too much of a perfomance hit
	for reporter_panel_container in _reporter_panel_containers:
		reporter_panel_container.queue_free()
	_reporter_panel_containers.clear()
	
	# we need to sort the nodes so that their reporter panels are instanciated in order of their distance from the camera
	var sort_by_distance = func (a, b):
		var camera_position = get_viewport().get_camera_3d().global_position
		var a_distance = camera_position.distance_to(a.global_position)
		var b_distance = camera_position.distance_to(b.global_position)
		return a_distance > b_distance
	
	var nodes_to_sort: Array[Node] = reporter_manager.get_top_level_nodes_with_reporters_for_multiple_nodes(nodes_whose_children_to_check)
	nodes_to_sort.sort_custom(sort_by_distance)
	
	for node in nodes_to_sort:
		var reporter_position = node.global_position
		var pos_2d = get_viewport().get_camera_3d().unproject_position(node.global_position)
		var reporter_panel_container = preload("res://scenes/components/reporter_panel_container.tscn").instantiate()
		add_child(reporter_panel_container)
		reporter_panel_container.position = pos_2d
		reporter_panel_container.add_panel(get_node_name(node), reporter_manager.get_report(node))
		_reporter_panel_containers.append(reporter_panel_container)
		
		for child_node in reporter_manager.get_all_nodes_with_reporters_within_node(node):
			reporter_panel_container.add_panel(get_node_name(child_node), reporter_manager.get_report(child_node))

func get_node_name(node) -> String:
		var node_name = node.name
		if node is GameItem:
			node_name = node.item_name
		return node_name
