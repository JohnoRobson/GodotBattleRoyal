class_name ItemUtils
extends Object

static func _get_child_shapes(item: GameItem) -> Array[Shape3D]:
	var shapes: Array[Shape3D] = []
	for child in item.get_children():
		if is_instance_of(child, CollisionShape3D):
			shapes.append((child as CollisionShape3D).shape)
	return shapes

# This is for making the items not clip through the ground when they are placed back in to the world
static func get_position_to_be_on_ground(item: GameItem, ground_position: Vector3) -> Vector3:
	var lowest_point: float = 0
	for shape: Shape3D in _get_child_shapes(item):
		var lowest_point_for_shape: float = 0
		if shape is BoxShape3D:
			lowest_point_for_shape = -shape.size.y
		elif shape is CapsuleShape3D:
			lowest_point_for_shape = -shape.height
		else:
			RoyalLogger.error("GameItem is using an unknown shape of type %s, add it to Inventory::add_half_items_height()" % [shape.get_class()])
		if lowest_point > lowest_point_for_shape:
			lowest_point = lowest_point_for_shape
	
	return ground_position + Vector3.UP * -lowest_point
