class_name InventorySlotData
extends Resource

@export var stack_size: int
var item: GameItem :
	get:
		return item
	set(value):
		if !is_empty() and item.item_used_up.is_connected(_remove_item):
			item.item_used_up.disconnect(_remove_item)
		if value != null:
			value.item_used_up.connect(_remove_item)
		if value == null:
			stack_size = 0
		item = value

func is_empty() -> bool:
	return item == null

func contains(_item: GameItem) -> bool:
	return (item == null && _item == null) || item == _item

# used for the item_used_up callback. Just set the item to null if you want to remove an item from a slot
func _remove_item() -> void:
	item = null
	stack_size = 0
