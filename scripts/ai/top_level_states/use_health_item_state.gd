class_name UseHealthItemState extends State

var medkit_pickup_countdown: int = -1
var medkit_pickup_routine_started: bool = false

func enter(controller: AiActorController):
	controller.set_aim_position(controller.actor.global_position)

func execute(controller: AiActorController):
	#var closest_health_in_world = controller.world.get_closest_item_with_traits(controller.actor.global_transform.origin, [GameItem.ItemTrait.HEALING])
	var health_in_inventory = InventoryUtils.switch_to_item_with_trait(controller.actor.weapon_inventory, GameItem.ItemTrait.HEALING)
	
	if health_in_inventory:
		medkit_pickup_routine_started = true
		medkit_pickup_countdown = 1
	else:
		controller.state_machine.change_state(DecisionMakingState.new())
	
	if medkit_pickup_routine_started:
		# do nothing, you are holding a medkit
		return

func execute_physics(controller: AiActorController):
	if medkit_pickup_routine_started and medkit_pickup_countdown > 0:
		medkit_pickup_countdown -= 1
		# health has been picked up
		controller.set_is_shooting(true)
	elif medkit_pickup_routine_started and medkit_pickup_countdown <= 0:
		# medkit has been used
		controller.set_is_shooting(false)
		controller.state_machine.change_state(DecisionMakingState.new())

func exit(controller: AiActorController):
	controller.set_move_direction(Vector2.ZERO)
	controller.set_is_exchanging_weapon(false)
	controller.set_is_shooting(false)
	pass

func get_name() -> String:
	return "UseHealthItemState"

func evaluate(factor_context: FactorContext) -> float:
	var health_factor: float = Factors.evaluate_health_factor(factor_context)
	var is_health_nearby: bool = factor_context.world.get_closest_item_with_traits(factor_context.target_actor.global_transform.origin, [GameItem.ItemTrait.HEALING]) != null
	var has_health_in_inventory: bool = InventoryUtils.contains_traits(factor_context.target_actor.weapon_inventory.inventory_data, [GameItem.ItemTrait.HEALING])
	
	if is_health_nearby or has_health_in_inventory:
		return health_factor
	else:
		return 0.0
