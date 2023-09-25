class_name InventoryUI
extends GridContainer

signal selected_slot_scrolled_up()
signal selected_slot_scrolled_down()
var _slots: Array[InventorySlotUi] = []

func _process(_delta):
	if Input.is_action_just_pressed("scroll_inventory_up"):
		selected_slot_scrolled_up.emit()
	if Input.is_action_just_pressed("scroll_inventory_down"):
		selected_slot_scrolled_down.emit()

func _on_inventory_changed(inventory_data: InventoryData, selected_slot_index: int):
	_slots = []
	for child in get_children():
		child.queue_free()
	
	for slot in inventory_data._slots:
		var ui_slot = preload("res://scenes/components/slot.tscn").instantiate()
		if !slot.is_empty():
			ui_slot.set_item(slot)
		add_child(ui_slot)
		_slots.append(ui_slot)
	
	if _slots.is_empty():
		return
	for slot in _slots:
		slot.outline.visible = false
	
	_slots[selected_slot_index].outline.visible = true
