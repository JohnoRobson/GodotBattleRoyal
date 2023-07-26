extends GameItem

@export var healing_amount: float

func use_item(actor: Actor):
	# get the actor's health component
	var health_component: Health = actor.get_node("Health")
	health_component.take_damage(-healing_amount)

func dispose_of_item():
	super()
