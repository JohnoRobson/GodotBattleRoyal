class_name ItemPickupText
extends Node3D

var game_item: GameItem
var text_state: InteractionText
@onready var item_name_text: Label3D = get_node("ItemNameText")
@onready var item_pickup_text: Label3D = get_node("ItemPickupText")
@onready var item_swap_text: Label3D = get_node("ItemSwapText")

enum InteractionText {
	NONE, SWAP, PICK_UP
}

func _ready() -> void:
	text_state = InteractionText.NONE

func set_item(_game_item: GameItem) -> void:
	game_item = _game_item
	item_name_text.text = _game_item.item_name
	global_position = _game_item.global_position + (Vector3.UP * 2)

func _process(delta: float) -> void:
	match text_state:
		InteractionText.NONE:
			item_pickup_text.hide()
			item_swap_text.hide()
		InteractionText.SWAP:
			item_pickup_text.hide()
			item_swap_text.show()
		InteractionText.PICK_UP:
			item_pickup_text.show()
			item_swap_text.hide()

func _physics_process(_delta) -> void:
	if game_item != null && game_item.is_inside_tree():
		global_position = game_item.global_position + (Vector3.UP * 2)
