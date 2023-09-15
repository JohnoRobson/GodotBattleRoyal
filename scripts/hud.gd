extends CanvasLayer

class_name Hud

@onready var ammo_count: Label = get_node("AmmoCount")
@onready var health: Label = get_node("Health")
@onready var inventory: GridContainer = get_node("Inventory")

var current_weapon: Weapon = null

func on_update_health(_old_value: float, new_value: float):
	health.text = "Health:" + str(new_value)

func on_update_ammo(current_ammo: int, max_ammo: int):
	ammo_count.text = "Ammo: " + str(current_ammo) + "/" + str(max_ammo)

func _on_weapon_swap(weapon):
	if current_weapon != null:
		current_weapon.update_ammo_ui.disconnect(on_update_ammo)

	current_weapon = weapon
	current_weapon.update_ammo_ui.connect(on_update_ammo)
	on_update_ammo(weapon._current_ammo, weapon.stats.max_ammo)

func _on_inventory_changed(slots: Array[InventorySlot]):
	print('ui')
	for child in inventory.get_children():
		child.queue_free()
	for slot in slots:
		var ui_slot = preload("res://scenes/components/slot.tscn").instantiate()
		ui_slot.set_item(slot)
		inventory.add_child(ui_slot)
