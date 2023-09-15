extends PanelContainer

@onready var label: Label = get_node("Label")
var slot_text = "test"

func _ready():
	label.text = slot_text

func set_item(inventory_slot: InventorySlot):
	slot_text = inventory_slot.item.item_name
