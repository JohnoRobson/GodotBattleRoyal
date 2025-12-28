class_name ActionHeal
extends TargetedAction
# Heals an actor

@export var healing: float = 1.0

func _init():
	action_name = self.Name.HEAL

func perform(_delta: float, _item_node: ActionStack.ItemNode) -> bool:
	for target in targets:
		if target is Actor:
			var actor: Actor = target as Actor
			actor.health.take_damage(-healing)
	return true
