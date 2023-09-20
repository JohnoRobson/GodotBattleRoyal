class_name ActionHeal
extends TargetedAction

@export var healing: float = 1.0

func _init():
	action_name = self.Name.HEAL

func perform(_delta: float, _game_item: GameItem) -> bool:
	for target in targets:
		if target is Actor:
			var actor: Actor = target as Actor
			actor.health.take_damage(-healing)
	return true
