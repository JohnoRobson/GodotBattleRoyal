extends Label3D

class_name ItemPickupText

var game_item: GameItem

func set_item(game_item: GameItem):
	self.game_item = game_item
	text = game_item.item_name
	global_position = game_item.global_position + (Vector3.UP * 2)

func _physics_process(delta):
	if game_item != null:
		global_position = game_item.global_position + (Vector3.UP * 2)
