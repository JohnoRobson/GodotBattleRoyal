class_name GameItem
extends RigidBody3D

var is_held: bool
var can_be_used: bool
@export var item_name: String = "Example Name"
@export var action: Action
@export var aim_function: AimFunction = AimFunction.new() # use default aim function
@export var traits: Array[ItemTrait] = []
@export_range(1, 64) var max_stack_size: int = 1

const DEFAULT_COLLISION_LAYER = 0b0100
const DEFAULT_COLLISION_MASK = 0b1111

signal item_updated()
signal item_used_up()
signal action_triggered(action: Action, game_item: GameItem)

enum ItemTrait {
	HEALING,
	EXPLOSIVE,
	FIREARM,
	THROWABLE,
	SELF_USE,
	AMMO
}

func _init() -> void:
	is_held = false
	can_be_used = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	# exists on the "Items" layer
	collision_layer = DEFAULT_COLLISION_LAYER
	# collides with everything
	collision_mask = DEFAULT_COLLISION_MASK
	freeze = is_held

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	pass

func _physics_process(_delta) -> void:
	if is_held:
		freeze = true
		collision_layer = 0b0000
	else:
		freeze = false
		collision_layer = DEFAULT_COLLISION_LAYER

func use_item(_actor: Actor) -> void:
	if can_be_used:
		action_triggered.emit(action, self)
		item_updated.emit()

func dispose_of_item() -> void:
	item_used_up.emit()
	queue_free()

# returns a vector in local space that points from the weapon to where the weapon should be pointing to hit the target
func get_aim_vector(target_global_position: Vector3) -> Vector3:
	return aim_function.aim_angle(target_global_position, global_position)

func has_trait(item_trait: ItemTrait) -> bool:
	return traits.has(item_trait)
