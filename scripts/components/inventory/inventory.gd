extends Node3D

# An inventory can hold a number of GameItems.
# It has methods for adding them to the inventory from the world
# and removing them from the inventory, placing them back in the world.
class_name Inventory

var items: Array[InventorySlot] = []
@export var _inventory_size: int = 6
#var selected_item_slot_index: int = -1

signal inventory_changed(items: Array[InventorySlot])

func _init(inventory_size: int = 6):
	_inventory_size = inventory_size

func add_item_to_inventory_from_world(item: GameItem) -> bool:
	if _is_item_in_inventory(item):
		return false

	if items.size() >= _inventory_size:
		return false
	
	if item.get_parent() != null:
		item.get_parent().remove_child(item)
	var slot = InventorySlot.new()
	slot._init(item, 1)
	items.append(slot)
	item.is_held = true
	inventory_changed.emit(items)
	
	return true

func remove_item_from_inventory_to_world(item: GameItem) -> bool:
	if !_is_item_in_inventory(item):
		return false
	
	for i in items.size():
		var slot: InventorySlot = items[i]
		if slot.contains(item):
			items.remove_at(i)
	item.position = Vector3.ZERO
	item.rotation = Vector3.ZERO

	# this is hacky
	# get_parent().get_parent().add_child(item)

	# item.global_position = position + Vector3.UP * 1
	# item.set_global_rotation_degrees(Vector3(0, 90, 0))
	item.is_held = false
	inventory_changed.emit(items)
	return true

func swap_item_from_world_to_inventory(world_item: GameItem, inventory_item: GameItem) -> bool:
	if !_is_item_in_inventory(inventory_item) or _is_item_in_inventory(world_item):
		return false

	if world_item.get_parent() != null:
		world_item.get_parent().remove_child(world_item)
	
	inventory_item.position = Vector3.ZERO
	inventory_item.rotation = Vector3.ZERO

	# this is hacky
	#get_parent().get_parent().add_child(inventory_item)

	inventory_item.global_position = position + Vector3.UP * 1
	inventory_item.set_global_rotation_degrees(Vector3(0, 90, 0))
	inventory_item.is_held = false

	items.append(world_item)
	world_item.is_held = true
	inventory_changed.emit(items)

	return true

func _is_item_in_inventory(item: GameItem) -> bool:
	return items.any(func(a): return a.contains(item))

func number_of_filled_slots() -> int:
	return items.size()
