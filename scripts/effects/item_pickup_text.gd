extends Node3D

class_name ItemPickupText

var game_item: GameItem
@onready var item_name_text: Label3D = get_node("ItemNameText")
@onready var item_interact_text: Label3D = get_node("ItemInteractText")

func _ready():
	item_interact_text.visible = false

func set_item(game_item: GameItem):
	self.game_item = game_item
	item_name_text.text = game_item.item_name
	global_position = game_item.global_position + (Vector3.UP * 2)

func set_show_interaction_text(show: bool):
	item_interact_text.visible = show

func _physics_process(delta):
	if game_item != null:
		global_position = game_item.global_position + (Vector3.UP * 2)
