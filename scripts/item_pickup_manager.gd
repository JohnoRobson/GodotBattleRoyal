class_name ItemInteractionManager
extends Node

# This class is for both displaying the correct ItemPickupText and filtering which items in an
# Actor's ItemInteractionArea should be picked up when the command to pick an item up is called

@export var item_area_actor: ItemInteractionArea
@export var item_area_cursor: ItemInteractionArea
@export var can_show_item_text: bool = true
@export var actor: Actor

var items_that_have_labels: Dictionary[GameItem, ItemPickupText]

func _ready() -> void:
	items_that_have_labels = {}

func _physics_process(_delta) -> void:
	if !can_show_item_text:
		return
	
	# check for items in area
	var items_in_actor_area: Array[GameItem] = item_area_actor.get_items_in_area()
	var items_in_cursor_area: Array[GameItem] = item_area_cursor.get_items_in_area()
	
	# remove labels
	for item in items_that_have_labels.keys():
		var label = items_that_have_labels.get(item)
		if item == null or (!items_in_actor_area.has(item) and !items_in_cursor_area.has(item)):
			# remove label
			items_that_have_labels.erase(item)
			label.queue_free()
	
	for item in items_in_actor_area:
		if !items_that_have_labels.has(item):
			# add a label
			var itemText: ItemPickupText = preload("res://scenes/effects/item_pickup_text.tscn").instantiate()
			add_child(itemText)
			itemText.set_item(item)
			items_that_have_labels[item] = itemText
		else:
			hide_interaction_text(items_that_have_labels[item])
	
	for item in items_in_cursor_area:
		if !items_that_have_labels.has(item):
			# add a label
			var itemText: ItemPickupText = preload("res://scenes/effects/item_pickup_text.tscn").instantiate()
			add_child(itemText)
			itemText.set_item(item)
			items_that_have_labels[item] = itemText
		if items_in_actor_area.has(item):
			show_iteraction_text(item, items_that_have_labels[item])
		else:
			hide_interaction_text(items_that_have_labels[item])

func show_iteraction_text(item: GameItem, item_text: ItemPickupText) -> void:
	if _can_pick_up_item(item):
		item_text.text_state = ItemPickupText.InteractionText.PICK_UP
	else:
		item_text.text_state = ItemPickupText.InteractionText.SWAP

func hide_interaction_text(item_text: ItemPickupText) -> void:
	item_text.text_state = ItemPickupText.InteractionText.NONE

func _can_pick_up_item(item: GameItem) -> bool:
	return actor.can_pick_up_item(item)

func get_item_that_cursor_is_over_and_is_in_interaction_range() -> GameItem:
	# check for items in area
	var items_in_actor_area: Array[GameItem] = item_area_actor.get_items_in_area()
	var items_in_cursor_area: Array[GameItem] = item_area_cursor.get_items_in_area()
	
	var items_in_both_areas: Array[GameItem] = []
	
	for item in items_in_cursor_area:
		if items_in_actor_area.has(item):
			items_in_both_areas.append(item)
	
	if items_in_both_areas.is_empty():
		return null
	else:
		return _get_closest_item(items_in_both_areas)

func _get_closest_item(item_array: Array[GameItem]) -> GameItem:
	var nearby_items: Array[GameItem] = item_array.filter(func(a): return a is GameItem)
	nearby_items.sort_custom(func(a, b): return item_area_cursor.global_transform.origin.distance_to(a.global_transform.origin) < item_area_cursor.global_transform.origin.distance_to(b.global_transform.origin))
	
	var closest_item: GameItem = null if nearby_items.is_empty() else nearby_items.front()
	return closest_item
