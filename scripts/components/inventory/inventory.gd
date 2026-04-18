class_name Inventory
extends Node3D
# An inventory can hold a number of GameItems.
# It has methods for adding them to the inventory from the world
# and removing them from the inventory, placing them back in the world.

@export var inventory_data: InventoryData
var _selected_slot_index: int = 0

signal inventory_changed(inventory_data: InventoryData, selected_slot_index: int, changed_slot_index: int)
signal return_item_to_world(item: GameItem, global_position_to_place_item: Vector3)

func _get_inventory_slots_that_can_accept_item(item: GameItem) -> Array[InventorySlotData]:
	if item == null:
		return []
	var matching_slots_with_free_space: Array[InventorySlotData] = inventory_data.get_slots_matching(func(a): return a.contains(item) and a.number_of_items() < item.max_stack_size)
	# sort these so when adding an item when the inventory already contains multiple matching
	# but not full stacks, it will be added to the largest one
	matching_slots_with_free_space.sort_custom(func(a, b): return a.number_of_items() > b.number_of_items())
	return matching_slots_with_free_space

func can_add_item_to_inventory(item: GameItem) -> bool:
	return !_get_inventory_slots_that_can_accept_item(item).is_empty() or has_empty_slots()

func _remove_item_from_parent_and_connect_signal(item: GameItem, slot: InventorySlotData) -> void:
	_emit_updates(inventory_data.get_index_of_slot(slot))
	
	if item.get_parent() != null:
		item.get_parent().remove_child(item)
	
	item.state = GameItem.ItemState.HELD
	connect_remove_signal(item)

func _add_item_to_valid_inventory_slot(item: GameItem, valid_slot: InventorySlotData) -> void:
	valid_slot.push_item(item)
	_remove_item_from_parent_and_connect_signal(item, valid_slot)
	_emit_updates(inventory_data.get_index_of_slot(valid_slot))

## Either adds the item to the selected slot, or if it's stackable and another slot has an instance of the item in it with free space then it adds the item to that slot
func add_item_to_inventory_from_world(item: GameItem) -> bool:
	if item == null:
		return false
	
	if !can_add_item_to_inventory(item):
		return false
	
	# try to add to selected slot
	if inventory_data.add_item_at_index(item, _selected_slot_index):
		_remove_item_from_parent_and_connect_signal(item, inventory_data._slots[_selected_slot_index])
		_emit_updates(_selected_slot_index)
		return true
	
	# Try to add as a stackable
	# find slots with the item and free space
	var matching_slots_with_free_space: Array[InventorySlotData] = _get_inventory_slots_that_can_accept_item(item)
	
	# add the item to the slot if you can
	if !matching_slots_with_free_space.is_empty():
		var slot = matching_slots_with_free_space[0]
		_add_item_to_valid_inventory_slot(item, slot)
		return true
	elif has_empty_slots():
		# else if there are empty slots, just throw it in
		var matching_empty_slots = inventory_data.get_slots_matching(func(a): return a.is_empty())
		var slot = matching_empty_slots[0]
		_add_item_to_valid_inventory_slot(item, slot)
		return true
	
	return false

# This for removing one (1) item
func remove_item_from_inventory_to_world(item: GameItem, item_global_position: Vector3, item_global_rotation: Vector3) -> bool:
	if !inventory_data.remove_item(item, _selected_slot_index):
		push_error("Failed to remove an item from an inventory")
		return false
	
	if item.get_parent() != null:
		item.get_parent().remove_child(item)
	
	_emit_updates(_selected_slot_index)
	
	# make it appear on the ground
	var new_position = RaycastUtils.get_position_on_the_ground(self, item_global_position)
	new_position = ItemUtils.get_position_to_be_on_ground(item, new_position);
	return_item_to_world.emit(item, new_position, item_global_rotation)
	
	disconnect_remove_signal(item)
	return true

# this swaps one item in the world with one item in the inventory (and any others in the slot) 
func swap_item_from_world_to_inventory(world_item: GameItem, inventory_item: GameItem) -> bool:
	var is_inventory_item_inside_inventory: bool = inventory_data.is_equivalent_item_in_inventory(inventory_item)
	
	if !is_inventory_item_inside_inventory:
		push_error("Failed to swap an item from an inventory")
		return false
	
	var world_global_position = world_item.global_position
	
	for slot in inventory_data._slots:
		if slot.contains(inventory_item):
			var points: Array[Vector3] = VectorUtils.get_radially_symmetrical_points(world_global_position, slot._items.size(), 1.5)
			var index = 0;
			while !slot.is_empty() and index < points.size():
				var new_item_position = RaycastUtils.get_position_on_the_ground(self, points[index] + Vector3.UP * 1)
				new_item_position = ItemUtils.get_position_to_be_on_ground(slot.get_item(), new_item_position);
				remove_item_from_inventory_to_world(slot.get_item(), new_item_position, Vector3(0, 90, 0))
				index += 1
			slot.push_item(world_item)
			break
	
	_remove_item_from_parent_and_connect_signal(world_item, inventory_data._slots[_selected_slot_index])
	return true

func add_or_swap_item_from_world_to_inventory(world_item: GameItem) -> void:
	# inventory, closest_item
	var did_pick_up_item = add_item_to_inventory_from_world(world_item)
	
	if did_pick_up_item:
		return
	
	# try for swap
	var held_item = get_one_item_in_selected_slot()
	if !did_pick_up_item && held_item != null && world_item != null:
		swap_item_from_world_to_inventory(world_item, held_item)

func drop_all_items_into_world(world_position: Vector3) -> void:
	# add a little bit of height so that the raycasts don't clip through the ground
	world_position = world_position + Vector3.UP * 0.1
	var total_items: int = 0

	for slot: InventorySlotData in inventory_data._slots:
		total_items += slot.number_of_items()
	
	var points: Array[Vector3] = VectorUtils.get_radially_symmetrical_points(world_position, total_items, 1.5)
	
	var current_index = 0
	for slot: InventorySlotData in inventory_data._slots:
		while !slot.is_empty():
			var new_item_position = RaycastUtils.get_position_in_direction_and_on_the_ground(self, world_position, points[current_index])
			new_item_position = ItemUtils.get_position_to_be_on_ground(slot.get_item(), new_item_position);
			remove_item_from_inventory_to_world(slot.get_item(), new_item_position, Vector3(0, 90, 0))
			current_index += 1

func number_of_filled_slots() -> int:
	return inventory_data.number_of_filled_slots()

func get_item_at_index(index: int) -> GameItem:
	return inventory_data.get_item_at_index(index)

func get_one_item_in_selected_slot() -> GameItem:
	return get_item_at_index(_selected_slot_index)

func get_all_items_in_slot(index: int) -> Array[GameItem]:
	return inventory_data.get_all_items_at_index(index)

func selected_slot_scrolled_up() -> void:
	var previous_slot_index = _selected_slot_index
	
	if inventory_data._slots.size() <= 1:
		_selected_slot_index = 0
	elif _selected_slot_index == inventory_data._slots.size() - 1:
		_selected_slot_index = 0
	else:
		_selected_slot_index += 1
	
	_emit_updates(previous_slot_index)

func selected_slot_scrolled_down() -> void:
	var previous_slot_index = _selected_slot_index
	
	if inventory_data._slots.size() <= 1:
		_selected_slot_index = 0
	elif _selected_slot_index == 0:
		_selected_slot_index = inventory_data._slots.size() - 1
	else:
		_selected_slot_index -= 1
	
	_emit_updates(previous_slot_index)

func emit_updates_for_active_item() -> void:
	inventory_changed.emit(inventory_data, _selected_slot_index, _selected_slot_index)

func _emit_updates(changed_slot_index: int) -> void:
	inventory_changed.emit(inventory_data, _selected_slot_index, changed_slot_index)

func connect_remove_signal(item: GameItem) -> void:
	if !item.remove_from_inventory_and_put_in_world.is_connected(remove_item_from_inventory_to_world):
		item.remove_from_inventory_and_put_in_world.connect(remove_item_from_inventory_to_world)

func disconnect_remove_signal(item: GameItem) -> void:
	if item.remove_from_inventory_and_put_in_world.is_connected(remove_item_from_inventory_to_world):
		item.remove_from_inventory_and_put_in_world.disconnect(remove_item_from_inventory_to_world)

func has_empty_slots() -> bool:
	return inventory_data.has_empty_slots()

func is_empty() -> bool:
	return inventory_data.is_empty()

func subtract_item_matching(filter: Callable) -> GameItem:
	var item_subtracted: GameItem = inventory_data.subtract_item_matching(filter)
	
	if item_subtracted != null:
		_emit_updates(_selected_slot_index)
	
	return item_subtracted
