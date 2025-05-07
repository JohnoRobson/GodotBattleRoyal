# An inventory can hold a number of GameItems.
# It has methods for adding them to the inventory from the world
# and removing them from the inventory, placing them back in the world.
class_name Inventory
extends Node3D

@export var inventory_data: InventoryData
var _selected_slot_index: int = 0

signal inventory_changed(inventory_data: InventoryData, selected_slot_index: int)
signal return_item_to_world(item: GameItem, global_position_to_place_item: Vector3)

func add_item_to_inventory_if_it_is_stackable_and_there_is_space(item: GameItem) -> bool:
	if item.max_stack_size <= 1:
		return false

	# find slots with the item and free space
	var matching_slots_with_free_space = inventory_data.get_slots_matching(func(a): return a.contains(item) and a.stack_size < item.max_stack_size)
	# add the item to the slot if you can
	if !matching_slots_with_free_space.is_empty():
		var slot = matching_slots_with_free_space[0]
		slot.push_item(item)
		emit_updates()
		return true
	elif has_empty_slots():
		# else if there are empty slots, just throw it in
		var matching_empty_slots = inventory_data.get_slots_matching(func(a): return a.is_empty())
		var slot = matching_empty_slots[0]
		slot.push_item(item)
		emit_updates()
		return true

	return false


## Either adds the item to the selected slot, or if it's stackable and another slot has an instance of the item in it with free space then it adds the item to that slot
func add_item_to_inventory_from_world(item: GameItem) -> bool:
	if !inventory_data.add_item_at_index(item, _selected_slot_index):
		push_error("Failed to add an item to an inventory")
		return false
	
	if item.get_parent() != null:
		item.get_parent().remove_child(item)
	
	item.is_held = true
	inventory_changed.emit(inventory_data, _selected_slot_index)
	connect_remove_signal(item)

	return true

func remove_item_from_inventory_to_world(item: GameItem) -> bool:
	if !inventory_data.remove_item(item):
		push_error("Failed to remove an item from an inventory")
		return false
	
	var item_global_position = item.global_position
	var item_global_rotation = item.global_rotation

	if item.get_parent() != null:
		item.get_parent().remove_child(item)

	item.is_held = false
	inventory_changed.emit(inventory_data, _selected_slot_index)
	return_item_to_world.emit(item, item_global_position, item_global_rotation)
	disconnect_remove_signal(item)

	return true

func swap_item_from_world_to_inventory(world_item: GameItem, inventory_item: GameItem) -> bool:
	if !inventory_data.swap_items(world_item, inventory_item):
		push_error("Failed to swap an item from an inventory")
		return false
	
	var world_global_position = world_item.global_position
	var world_global_rotation = world_item.global_rotation

	if world_item.get_parent() != null:
		world_item.get_parent().remove_child(world_item)
	
	world_item.is_held = true
	inventory_item.is_held = false
	
	inventory_changed.emit(inventory_data, _selected_slot_index)
	return_item_to_world.emit(inventory_item, world_global_position, world_global_rotation)
	connect_remove_signal(world_item)
	disconnect_remove_signal(inventory_item)

	return true

func _is_item_in_inventory(item: GameItem) -> bool:
	return inventory_data._is_item_in_inventory(item)

func number_of_filled_slots() -> int:
	return inventory_data.number_of_filled_slots()

func get_item_at_index(index: int) -> GameItem:
	return inventory_data.get_item_at_index(index)

func get_selected_item() -> GameItem:
	return get_item_at_index(_selected_slot_index)

func selected_slot_scrolled_up() -> void:
	if inventory_data._slots.size() <= 1:
		_selected_slot_index = 0
	elif _selected_slot_index == inventory_data._slots.size() - 1:
		_selected_slot_index = 0
	else:
		_selected_slot_index += 1

	inventory_changed.emit(inventory_data, _selected_slot_index)

func selected_slot_scrolled_down() -> void:
	if inventory_data._slots.size() <= 1:
		_selected_slot_index = 0
	elif _selected_slot_index == 0:
		_selected_slot_index = inventory_data._slots.size() - 1
	else:
		_selected_slot_index -= 1

	inventory_changed.emit(inventory_data, _selected_slot_index)

func emit_updates():
	inventory_changed.emit(inventory_data, _selected_slot_index)

func connect_remove_signal(item: GameItem):
	if !item.remove_from_inventory_and_put_in_world.is_connected(remove_item_from_inventory_to_world):
		item.remove_from_inventory_and_put_in_world.connect(remove_item_from_inventory_to_world)

func disconnect_remove_signal(item: GameItem):
	if item.remove_from_inventory_and_put_in_world.is_connected(remove_item_from_inventory_to_world):
		item.remove_from_inventory_and_put_in_world.disconnect(remove_item_from_inventory_to_world)

func has_empty_slots() -> bool:
	return inventory_data.has_empty_slots()

func is_empty() -> bool:
	return inventory_data.is_empty()

func subtract_item_matching(filter: Callable) -> GameItem:
	var item_subtracted: GameItem = inventory_data.subtract_item_matching(filter)

	if item_subtracted != null:
		inventory_changed.emit(inventory_data, _selected_slot_index)
	
	return item_subtracted
