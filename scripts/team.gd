class_name Team extends Node

@onready var members: Array[Actor] = []

var display_name: String

func _init(given_name:String = "") -> void:
	if given_name == "": # team name cannot be empty
		var name_generator = NameGenerator.new()
		display_name = name_generator.generate_team_name()
	else:
		display_name = given_name

func add_member(member:Actor) -> void:
	members.append(member)
	member.team = self

func remove_member(member:Actor) -> void:
	members.erase(member)
	member.team = null

func get_members() -> Array[Actor]:
	return members

func get_average_location() -> Vector3:
	if members.size() == 0:
		return Vector3.ZERO

	var accumulated_position = Vector3.ZERO
	for actor in members:
		if is_instance_valid(actor):
			accumulated_position += actor.global_position
	
	return accumulated_position / members.size()

func get_average_health() -> int:
	if members.size() == 0:
		return 0

	var accumulated_health = 0
	for actor in members:
		if is_instance_valid(actor):
			accumulated_health += actor.health.current_health
	return accumulated_health / members.size()
