class_name ActionDamage
extends TargetedAction

@export var damage: float = 1.0

func _init():
	action_name = self.Name.DAMAGE

func perform(_delta: float, game_item: GameItem) -> bool:
	for target in targets:
		if target is Actor:
			var actor: Actor = target as Actor
			actor.get_node("Hurtbox").take_damage(damage, game_item.global_position, (actor.global_position - game_item.global_position).normalized())
	return true
