extends Area3D

class_name ItemPickupArea

var items_that_have_labels: Dictionary # GameItem to Label Dict

func _ready():
	items_that_have_labels = {}

func _physics_process(_delta):
	# check for items in area
	var items_in_area: Array[GameItem] = get_items_in_area()
	
	# remove labels
	for item in items_that_have_labels.keys():
		if !items_in_area.has(item):
			# remove label
			var label_to_remove = items_that_have_labels.get(item)
			items_that_have_labels.erase(item)
			label_to_remove.queue_free()
	
	for item in items_in_area:
		if !items_that_have_labels.has(item):
			# add a label
			var itemText: ItemPickupText = preload("res://scenes/effects/item_pickup_text.tscn").instantiate()
			add_child(itemText)
			itemText.set_item(item)
			items_that_have_labels[item] = itemText

	pass

func get_items_in_area() -> Array[GameItem]:
	var typed_game_item_array: Array[GameItem] = []
	var untyped_array_of_items_in_area = get_overlapping_bodies().filter(func(a): return a is GameItem && !a.is_held)
	typed_game_item_array.assign(untyped_array_of_items_in_area) # have to do it like this in order to return a typed array
	return typed_game_item_array


func item_is_in_area(item: GameItem):
	return get_items_in_area().has(item)
