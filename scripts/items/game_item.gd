class_name GameItem
extends RigidBody3D

var is_held: bool
var can_be_used: bool
@export var item_name: String = "Example Name"
@export var action: Action
@export var aim_function: AimFunction = null
@export var traits: Array[ItemTrait] = []

signal item_updated()
signal item_used_up()
signal action_triggered(action: Action, game_item: GameItem)
signal remove_from_inventory_and_put_in_world(game_item: GameItem)

enum ItemTrait {
	HEALING,
	EXPLOSIVE,
	FIREARM,
	THROWABLE,
	SELF_USE
}

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

# returns a vector that points from the weapon to the target, in local space
# Points straight ahead if no aim function is set
func get_aim_vector(target_global_position: Vector3) -> Vector3:
	var aim_direction = target_global_position - global_position
	aim_direction = Vector3(aim_direction.x, 0.0, aim_direction.z)

	if (aim_function != null):
		aim_direction = aim_function.aim_angle(target_global_position, global_position)
	
	return aim_direction

func has_trait(item_trait: ItemTrait):
	return traits.has(item_trait)
