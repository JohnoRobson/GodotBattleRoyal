class_name InventorySlotUi
extends PanelContainer

@onready var label: Label = get_node("Label")
@onready var outline: ReferenceRect = $Outline
@onready var count: Label = $CountLabel

var slot_text = ""
var count_text = ""

func _ready():
	label.text = slot_text
	count.text = count_text

func set_item(inventory_slot: InventorySlotData):
	slot_text = inventory_slot.get_item().item_name if inventory_slot.get_item() != null else ""
	count_text = str(inventory_slot.number_of_items()) if inventory_slot.number_of_items() > 1 else ""
