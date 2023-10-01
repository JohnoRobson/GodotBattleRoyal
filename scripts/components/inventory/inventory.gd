# An inventory can hold a number of GameItems.
# It has methods for adding them to the inventory from the world
# and removing them from the inventory, placing them back in the world.
class_name Inventory
extends Node3D

@export var inventory_data: InventoryData
var _selected_slot_index: int = 0

signal inventory_changed(inventory_data: InventoryData, selected_slot_index: int)
signal return_item_to_world(item: GameItem, global_position_to_place_item: Vector3)

func add_item_to_inventory_from_world(item: GameItem) -> bool:
	if !inventory_data.add_item_at_index(item, _selected_slot_index):
		push_error("Failed to add an item to an inventory")
		return false
	
	if item.get_parent() != null:
		item.get_parent().remove_child(item)
	
	item.is_held = true
	inventory_changed.emit(inventory_data, _selected_slot_index)
	
	return true

func remove_item_from_inventory_to_world(item: GameItem) -> bool:
	if !inventory_data.remove_item(item):
		push_error("Failed to remove an item from an inventory")
		return false

	if item.get_parent() != null:
		item.get_parent().remove_child(item)

	item.position = Vector3.ZERO
	item.rotation = Vector3.ZERO
	item.is_held = false
	inventory_changed.emit(inventory_data, _selected_slot_index)
	return_item_to_world.emit(item, global_position + Vector3.UP * 1)

	return true

func swap_item_from_world_to_inventory(world_item: GameItem, inventory_item: GameItem) -> bool:
	if !inventory_data.swap_items(world_item, inventory_item):
		push_error("Failed to swap an item from an inventory")
		return false

	if world_item.get_parent() != null:
		world_item.get_parent().remove_child(world_item)
	
	world_item.is_held = true

	inventory_changed.emit(inventory_data, _selected_slot_index)
	inventory_item.position = Vector3.ZERO
	inventory_item.rotation = Vector3.ZERO
	inventory_item.is_held = false
	return_item_to_world.emit(inventory_item, global_position + Vector3.UP * 1)

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
