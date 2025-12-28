class_name FindAmmoState extends State

const acceptable_number_of_reloads_for_a_weapon: int = 1

var _ammo_category_to_find: AmmoType.AmmoCategory

func enter(_controller: AiActorController):
	pass

func execute(controller: AiActorController):
	var find_item_state := FindItemState.new([], [_ammo_category_to_find])
	controller.state_machine.change_state(find_item_state)

func execute_physics(_controller: AiActorController):
	pass

func exit(_controller: AiActorController):
	pass

func get_name() -> String:
	return "FindAmmoState"

func evaluate(factor_context: FactorContext) -> float:
	# find weapons that the actor has
	var weapons: Array[GameItem] = InventoryUtils.get_all_weapons(factor_context.target_actor.inventory)
	
	var has_acceptable_amount_of_ammo_for_weapon: bool = false
	
	# find out how much ammo the actor has for those weapons
	var weapons_and_number_of_reloads_per_weapon: Dictionary[Weapon, int] = {}
	for weapon: Weapon in weapons:
		var number_of_ammo_in_inventory: int = InventoryUtils.get_all_ammo_of_category(factor_context.target_actor.inventory, weapon.stats.ammo_category).size()
		weapons_and_number_of_reloads_per_weapon[weapon] = number_of_ammo_in_inventory
		if number_of_ammo_in_inventory >= acceptable_number_of_reloads_for_a_weapon:
			has_acceptable_amount_of_ammo_for_weapon = true
	
	if weapons.is_empty():
		return 0.0
	else:
		# find weapon that also has ammo nearby and use that to calculate the score
		for weapon: Weapon in weapons_and_number_of_reloads_per_weapon.keys():
			#var reloads = weapons_and_number_of_reloads_per_weapon[weapon]
			var closest_ammo:Ammo = factor_context.world.get_closest_ammo_of_category(factor_context.target_actor.global_transform.origin, weapon.stats.ammo_category)
			
			if closest_ammo != null and !has_acceptable_amount_of_ammo_for_weapon:
				_ammo_category_to_find = closest_ammo.ammo_type.ammo_category
				return 0.5
	return 0.0
