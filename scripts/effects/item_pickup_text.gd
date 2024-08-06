extends Node3D

class_name ItemPickupText

var game_item: GameItem
@onready var item_name_text: Label3D = get_node("ItemNameText")
@onready var item_interact_text: Label3D = get_node("ItemInteractText")

func _ready():
	item_interact_text.visible = false

func set_item(_game_item: GameItem):
	game_item = _game_item
	item_name_text.text = _game_item.item_name
	global_position = _game_item.global_position + (Vector3.UP * 2)

func set_show_interaction_text(_show: bool):
	item_interact_text.visible = _show

func _physics_process(_delta):
	if game_item != null && game_item.is_inside_tree():
		global_position = game_item.global_position + (Vector3.UP * 2)
