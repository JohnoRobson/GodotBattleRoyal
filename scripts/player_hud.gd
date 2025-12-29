class_name PlayerHud
extends Control

@onready var ammo_count: Label = get_node("AmmoCount")
@onready var health: Label = get_node("Health")
@onready var inventory_ui: InventoryUI = get_node("Inventory")

var current_weapon: GameItem = null

func on_update_health(_old_value: float, new_value: float) -> void:
	health.text = "Health:" + str(new_value)

func on_update_ammo(current_ammo: int, max_ammo: int) -> void:
	ammo_count.text = "Ammo: " + str(current_ammo) + "/" + str(max_ammo)

func _on_weapon_swap(game_item) -> void:
	if current_weapon != null:
		current_weapon.update_ammo_ui.disconnect(on_update_ammo)
		current_weapon = null
	
	if game_item is Weapon:
		current_weapon = game_item
		current_weapon.update_ammo_ui.connect(on_update_ammo)
		if game_item._ammo != null:
			on_update_ammo(game_item._ammo.current_ammo_in_magazine, game_item._ammo.ammo_type.ammo_in_full_magazine)
		else:
			on_update_ammo(0, 0)
	else:
		on_update_ammo(0, 0)

func _on_inventory_changed(inventory_data: InventoryData, selected_slot_index: int, changed_slot_index: int) -> void:
	inventory_ui._on_inventory_changed(inventory_data, selected_slot_index, changed_slot_index)
