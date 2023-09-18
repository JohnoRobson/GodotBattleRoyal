extends PanelContainer

class_name InventorySlotUi

@onready var label: Label = get_node("Label")
@onready var outline: ReferenceRect = $Outline

var slot_text = ""

func _ready():
	label.text = slot_text

func set_item(inventory_slot: InventorySlotData):
	slot_text = inventory_slot.item.item_name
