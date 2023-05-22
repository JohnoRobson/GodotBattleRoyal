extends RigidBody3D

class_name GameItem

var is_held: bool

func _init():
	is_held = false

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

# inventory stuff goes here later
