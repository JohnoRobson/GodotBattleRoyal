extends Area3D

class_name ItemPickupArea

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(_delta):
	# check for items in area

	# add labels

	# remove labels from items that are now out of the area

	pass

func get_items_in_area() -> Array[GameItem]:
	var typed_game_item_array: Array[GameItem] = []
	var untyped_array_of_items_in_area = get_overlapping_bodies().filter(func(a): return a is GameItem && !a.is_held)
	typed_game_item_array.assign(untyped_array_of_items_in_area) # have to do it like this in order to return a typed array
	return typed_game_item_array


func item_is_in_area(item: GameItem):
	return get_items_in_area().has(item)
