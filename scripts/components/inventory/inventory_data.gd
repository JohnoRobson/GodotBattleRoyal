class_name InventoryData
extends Resource

@export var _slots: Array[InventorySlotData] = []

func is_equivalent_item_in_inventory(item: GameItem) -> bool:
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

	return _slots[index].get_item()

func add_item_at_index(item: GameItem, slot_index: int) -> bool:
	return _slots[slot_index].push_item(item)

func add_item(item: GameItem) -> bool:
	var added_item: bool = false

	for slot in _slots:
		var did_add_item = slot.push_item(item)
		if did_add_item:
			added_item = true
			break
	
	return added_item

func remove_item(item: GameItem) -> bool:
	if !is_equivalent_item_in_inventory(item):
		return false

	for i in _slots.size():
		var slot = _slots[i]
		if slot.contains(item):
			slot.pop_item()
			return true
	
	# this shouldn't happen
	push_error("Failed to remove an item from an inventory after confirming it was inside the inventory")
	return false

func swap_items(item_outside_inventory: GameItem, item_inside_inventory: GameItem) -> bool:
	var is_inside_item_inside_inventory: bool = is_equivalent_item_in_inventory(item_inside_inventory)

	if !is_inside_item_inside_inventory:
		return false
	
	for slot in _slots:
		if slot.contains(item_inside_inventory):
			# empty the slot into the world
			slot.pop_item()
			slot.push_item(item_outside_inventory)
			return true
	
	# this shouldn't happen
	push_error("Failed to swap an item from an inventory after confirming it was inside the inventory")
	return false

func get_slots_matching(filter: Callable) -> Array[InventorySlotData]:
	var slots_matching_filter: Array[InventorySlotData]

	for slot in _slots:
		var test = filter.call(slot)
		if test:
			slots_matching_filter.append(slot)
	
	return slots_matching_filter

func subtract_item_matching(filter: Callable) -> GameItem:
	var matching_slots: Array[InventorySlotData] = get_slots_matching(filter)

	if matching_slots.is_empty():
		return null
	
	var first_slot_matching_the_filter := matching_slots[0]
	return first_slot_matching_the_filter.pop_item()

func get_index_of_slot(slot: InventorySlotData) -> int:
	for i in range(0, _slots.size()):
		if (_slots[i] == slot):
			return i
	
	push_error("Failed to find the index of a slot")
	return 0