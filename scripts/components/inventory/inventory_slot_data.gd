class_name InventorySlotData
extends Resource

var _items: Array[GameItem]

func push_item(item: GameItem) -> bool:
	if item == null:
		return false
	if _items.size() >= item.max_stack_size:
		return false
	if !_items.is_empty() and !contains(item):
		return false
	
	item.item_used_up.connect(pop_item)
	_items.push_back(item)
	return true

func pop_item() -> GameItem:
	var item: GameItem = null if _items.is_empty() else _items.pop_back()
	if item != null and item.item_used_up.is_connected(pop_item):
		item.item_used_up.disconnect(pop_item)
	return item

func get_item() -> GameItem:
	return _items[_items.size() - 1] if !_items.is_empty() else null

func is_empty() -> bool:
	return _items.is_empty()

func contains(_item: GameItem) -> bool:
	var item = get_item()
	return (item != null && _item != null) && _item.item_name == item.item_name && _item.traits.size() == item.traits.size() && _item.traits.all(func(a): return a in item.traits)

func number_of_items() -> int:
	return _items.size()
