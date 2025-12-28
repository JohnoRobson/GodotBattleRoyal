class_name Ammo extends GameItem

@export var ammo_type: AmmoType
var current_ammo_in_magazine: int:
	set(new_value):
		current_ammo_in_magazine = clamp(new_value, 0, ammo_type.ammo_in_full_magazine)

func _ready():
	current_ammo_in_magazine = ammo_type.ammo_in_full_magazine
