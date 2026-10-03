class_name ActionCreate
extends Action
## Creates a new game item

@export var game_items_to_create: Array[PackedScene]

## Trigger the first action of the new game item
@export var cascade_action: bool = true

## Item spawn radius from the center point
@export var spawn_radius: float = 0

func _init() -> void:
	action_name = self.Name.CREATE

func perform(_delta: float, item_node: ActionStack.ItemNode) -> bool:
	var current_game_item: GameItem = item_node.game_item
	
	var spawn_points: Array[Vector3] = VectorUtils.get_radially_symmetrical_points(current_game_item.position, game_items_to_create.size(), 1)
	
	for game_item_to_create: PackedScene in game_items_to_create:
		var new_game_item = game_item_to_create.instantiate()
		item_node.data[Action.Keys.WORLD].return_item_to_world(new_game_item, spawn_points.pop_back(), current_game_item.rotation)
		
		new_game_item.linear_velocity = current_game_item.linear_velocity
		new_game_item.angular_velocity = current_game_item.angular_velocity
		
		var action_system: ActionSystem = item_node.data[Action.Keys.ACTION_SYSTEM]
		new_game_item.action_triggered.connect(action_system.action_triggered)
		
		if (cascade_action):
			item_node.child_nodes.append(ActionStack.ItemNode.new(new_game_item.action, new_game_item, item_node))
	
	return true
