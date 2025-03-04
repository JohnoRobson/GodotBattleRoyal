class_name InventoryData
extends Resource

@export var _slots: Array[InventorySlotData] = []

func is_item_in_inventory(item: GameItem) -> bool:
	return _slots.any(func(a): return a.contains(item))

func number_of_slots() -> int:
	return _slots.size()

func number_of_filled_slots() -> int:
	return _slots.filter(func(a): return !a.is_empty()).size()

func has_empty_slots() -> bool:
	for slot in _slots:
		if slot.is_empty():
			return true
	return false

func is_empty() -> bool:
	return _slots.all(func(slot): slot.is_empty())

func get_item_at_index(index: int) -> GameItem:
	if index > _slots.size() - 1 || index < 0:
		return null

	return _slots[index].item

func is_slot_at_index_empty(slot_index: int) -> bool:
	if slot_index < 0 or slot_index > _slots.size() - 1:
		return false
	return _slots[slot_index].item == null

func add_item_at_index(item: GameItem, slot_index: int) -> bool:
	if !is_slot_at_index_empty(slot_index):
		return false
	
	_slots[slot_index].item = item

	return true

func add_item(item: GameItem) -> bool:
	if !has_empty_slots():
		return false
	
	# add item to first empty slot
	for slot in _slots:
		if slot.is_empty():
			slot.item = item
			return true
	
	# this shouldn't happen
	push_error("Failed to add an item to an inventory after confirming it had space for it")
	return false

func remove_item(item: GameItem) -> bool:
	if !is_item_in_inventory(item):
		return false

	for i in _slots.size():
		var slot = _slots[i]
		if slot.contains(item):
			slot.item = null
			return true
	
	# this shouldn't happen
	push_error("Failed to remove an item from an inventory after confirming it was inside the inventory")
	return false

func swap_items(item_outside_inventory: GameItem, item_inside_inventory: GameItem) -> bool:
	if !(!is_item_in_inventory(item_outside_inventory) and is_item_in_inventory(item_inside_inventory)):
		return false
	
	for i in _slots.size():
		var slot = _slots[i]
		if slot.contains(item_inside_inventory):
			slot.item = item_outside_inventory
			return true
	
	# this shouldn't happen
	push_error("Failed to swap an item from an inventory after confirming it was inside the inventory")
	return false

func get_slots_matching(filter: Callable) -> Array:
	var slots_matching_filter: Array[InventorySlotData]

	for slot in _slots:
		if filter.call(slot.item):
			slots_matching_filter.append(slot)
	
	return slots_matching_filter

func subtract_item_matching(filter: Callable) -> GameItem:
	var matching_slots: Array[InventorySlotData] = get_slots_matching(filter)

	if matching_slots.is_empty():
		return null
	
	var first_slot_matching_the_filter := matching_slots[0]
	var item = first_slot_matching_the_filter.item
	first_slot_matching_the_filter.stack_size -= 1
	return item
