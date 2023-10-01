extends Area3D

class_name ItemInteractionArea

@export var show_pickup_text: bool = false
@export var show_any_text: bool = false

func get_items_in_area() -> Array[GameItem]:
	var typed_game_item_array: Array[GameItem] = []
	var untyped_array_of_items_in_area = get_overlapping_bodies().filter(func(a): return a is GameItem && !a.is_held)
	typed_game_item_array.assign(untyped_array_of_items_in_area) # have to do it like this in order to return a typed array
	return typed_game_item_array

func item_is_in_area(item: GameItem):
	return get_items_in_area().has(item)
