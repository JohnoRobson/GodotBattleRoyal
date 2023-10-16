class_name ActionDamage
extends TargetedAction

# Does damage to an actor

@export var damage: float = 1.0

func _init():
	action_name = self.Name.DAMAGE

func perform(_delta: float, item_node: ActionStack.ItemNode) -> bool:
	for target in targets:
		if target is Actor:
			var actor: Actor = target as Actor
			actor.get_node("Rotator/Body/Hurtbox").take_damage(damage, item_node.data.get(self.Keys.POSITION), (actor.global_position - item_node.data.get(self.Keys.POSITION)).normalized())
	return true
