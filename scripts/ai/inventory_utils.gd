class_name InventoryUtils

# Checks the contents of the InventoryData and returns a list of ItemTraits from GameItems in it
static func get_traits(inventory_data: InventoryData) -> Array[GameItem.ItemTrait]:
	# throw the traits into a dict acting as a set
	var traits_in_inventory = {}
	var items_in_inventory = inventory_data._slots.map(func(a): return a.item).filter(func(a): return a != null)
	for item: GameItem in items_in_inventory:
		for item_trait: GameItem.ItemTrait in item.traits:
			traits_in_inventory[item_trait] = true
	
	# array casting trick
	var trait_array: Array[GameItem.ItemTrait] = []
	trait_array.append_array(traits_in_inventory.keys())
	return trait_array

# Checks the contents of the InventoryData and returns a list of ItemTraits from GameItems in it
static func contains_trait(inventory_data: InventoryData, desired_trait: GameItem.ItemTrait) -> bool:
	return inventory_data._slots.any(func(a): return _item_slot_has_trait(a, desired_trait))

static func switch_to_empty_slot(inventory: Inventory) -> bool:
	if !inventory.has_empty_slots():
		return false
	
	var empty_slot_is_selected = inventory.get_selected_item() == null
	
	if empty_slot_is_selected:
		return true
	
	for number in range(0, inventory.inventory_data.number_of_slots()):
		inventory.selected_slot_scrolled_up()
		empty_slot_is_selected = inventory.get_selected_item() == null
		if empty_slot_is_selected:
			return true
	
	return false

static func switch_to_item_with_trait(inventory: Inventory, item_trait: GameItem.ItemTrait) -> bool:
	if !inventory.has_empty_slots():
		return false
	
	var item_slot_with_trait_is_selected = _item_slot_has_trait(inventory.inventory_data._slots[inventory._selected_slot_index], item_trait)
	
	if item_slot_with_trait_is_selected:
		return true
	
	for number in range(0, inventory.inventory_data.number_of_slots()):
		inventory.selected_slot_scrolled_up()
		item_slot_with_trait_is_selected = _item_slot_has_trait(inventory.inventory_data._slots[inventory._selected_slot_index], item_trait)
		if item_slot_with_trait_is_selected:
			return true
	
	return false

static func _item_slot_has_trait(slot: InventorySlotData, desired_trait: GameItem.ItemTrait) -> bool:
	if slot.is_empty():
		return false
	else:
		for item_trait: GameItem.ItemTrait in slot.item.traits:
			if item_trait == desired_trait:
				return true
	return false
