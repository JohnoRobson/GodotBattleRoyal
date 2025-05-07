class_name InventoryUtils

# Checks the contents of the InventoryData and returns a list of ItemTraits from GameItems in it
static func get_traits(inventory_data: InventoryData) -> Array[GameItem.ItemTrait]:
	# throw the traits into a dict acting as a set
	var traits_in_inventory = {}
	var items_in_inventory = inventory_data._slots.filter(func(a): return !a.is_empty()).map(func(a): return a.get_item())
	for item: GameItem in items_in_inventory:
		for item_trait: GameItem.ItemTrait in item.traits:
			traits_in_inventory[item_trait] = true
	
	# array casting trick
	var trait_array: Array[GameItem.ItemTrait] = []
	trait_array.append_array(traits_in_inventory.keys())
	return trait_array

# Checks the contents of the InventoryData and returns a list of ItemTraits from GameItems in it
static func contains_traits(inventory_data: InventoryData, desired_traits: Array[GameItem.ItemTrait]) -> bool:
	return inventory_data._slots.any(func(a): return _item_slot_has_traits(a, desired_traits))

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
	if inventory.is_empty():
		return false
	
	var item_slot_with_trait_is_selected = _item_slot_has_traits(inventory.inventory_data._slots[inventory._selected_slot_index], [item_trait])
	
	if item_slot_with_trait_is_selected:
		return true
	
	for number in range(0, inventory.inventory_data.number_of_slots()):
		inventory.selected_slot_scrolled_up()
		item_slot_with_trait_is_selected = _item_slot_has_traits(inventory.inventory_data._slots[inventory._selected_slot_index], [item_trait])
		if item_slot_with_trait_is_selected:
			return true
	
	return false

static func _item_slot_has_traits(slot: InventorySlotData, desired_traits: Array[GameItem.ItemTrait]) -> bool:
	if slot.is_empty():
		return false
	else:
		return desired_traits.all(func(a): return a in slot.get_item().traits)

static func get_all_items_in_inventory(inventory: Inventory) -> Array[GameItem]:
	var items: Array[GameItem] = []
	for slot: InventorySlotData in inventory.inventory_data._slots:
		if !slot.is_empty():
			items.append(slot.get_item())
	return items

static func switch_to_item(inventory: Inventory, item: GameItem) -> bool:
	var item_slot_with_trait_is_selected: bool = inventory.get_selected_item() == item
	for number in range(0, inventory.inventory_data.number_of_slots()):
		inventory.selected_slot_scrolled_up()
		item_slot_with_trait_is_selected = inventory.get_selected_item() == item
		if item_slot_with_trait_is_selected:
			return true
	
	return false
	
static func get_all_weapons(inventory: Inventory) -> Array[GameItem]:
	var items: Array[GameItem] = get_all_items_in_inventory(inventory)
	return items.filter(func(a): return a.traits.has(GameItem.ItemTrait.FIREARM))

static func get_all_ammo_of_category(inventory: Inventory, ammo_category: AmmoType.AmmoCategory) -> Array[GameItem]:
	var items: Array[GameItem] = get_all_items_in_inventory(inventory)
	var ammo: Array[GameItem] = items.filter(func(a): return a.traits.has(GameItem.ItemTrait.AMMO)).filter(func(a): return (a as Ammo).ammo_type.ammo_category == ammo_category)
	return ammo
