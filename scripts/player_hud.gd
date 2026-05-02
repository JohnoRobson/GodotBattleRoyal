class_name PlayerHud
extends Control

@onready var ammo_count: Label = get_node("AmmoPanel/VBoxContainer/AmmoCount")
@onready var weapon_name: Label = get_node("AmmoPanel/VBoxContainer/WeaponName")
@onready var health: Label = get_node("HealthPanel/VBoxContainer/Health")
@onready var inventory_ui: InventoryUI = get_node("Inventory")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

var current_weapon: GameItem = null

func _ready():
	ammo_count.text = ""
	weapon_name.text = ""

func on_update_health(_old_value: float, new_value: float) -> void:
	health.text = "Health:" + str(new_value)
	animation_player.play("Health")

func on_update_ammo(current_ammo: int, max_ammo: int, animate: bool = true) -> void:
	if max_ammo > 0 or current_ammo > 0:
		ammo_count.text = "Ammo: " + str(current_ammo) + "/" + str(max_ammo)
		if animate:
			animation_player.play("Ammo")
	else:
		ammo_count.text = ""

func _on_weapon_swap(game_item: GameItem) -> void:
	if current_weapon != null and current_weapon is Weapon:
		current_weapon.update_ammo_ui.disconnect(on_update_ammo)
		current_weapon = null
	
	if game_item != null:
		current_weapon = game_item
		weapon_name.text = game_item.item_name
		if game_item is Weapon:
			current_weapon.update_ammo_ui.connect(on_update_ammo)	
			
			if game_item._ammo != null:
				on_update_ammo(game_item._ammo.current_ammo_in_magazine, game_item._ammo.ammo_type.ammo_in_full_magazine, false)
			else:
				on_update_ammo(-1, -1, false)
		else:
			on_update_ammo(-1, -1, false)
	else:
		on_update_ammo(-1, -1, false)
		weapon_name.text = ""

func _on_inventory_changed(inventory_data: InventoryData, selected_slot_index: int, changed_slot_index: int) -> void:
	inventory_ui._on_inventory_changed(inventory_data, selected_slot_index, changed_slot_index)
