extends Resource
class_name InventorySlot

@export var stack_size: int
@export var item: GameItem

func _init(_item = null, _stack_size = 0):
	item = _item
	stack_size = _stack_size

func contains(_item: GameItem) -> bool:
	return (_item == null && item == null) || typeof(_item) == typeof(item)