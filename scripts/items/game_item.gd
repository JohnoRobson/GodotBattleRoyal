class_name GameItem

extends RigidBody3D

var is_held: bool
var can_be_used: bool
@export var item_name: String = "Example Name"
@export var action: Action

signal item_updated()
signal item_used_up()
signal action_triggered(action: Action, game_item: GameItem)
signal remove_from_inventory_and_put_in_world(game_item: GameItem)

func _init():
	is_held = false
	can_be_used = true

# Called when the node enters the scene tree for the first time.
func _ready():
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	# exists on the "Items" layer
	collision_layer = 0b0100
	# collides with everything
	collision_mask = 0b0111
	freeze = is_held

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(_delta):
	freeze = is_held

func use_item(_actor: Actor):
	if can_be_used:
		action_triggered.emit(action, self)
		item_updated.emit()

func dispose_of_item():
	item_used_up.emit()
	queue_free()
