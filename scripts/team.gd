class_name Team extends Node

@onready var members: Array[Actor] = []

var display_name: String

func _init():
	var name_generator = NameGenerator.new()
	display_name = name_generator.generate_team_name()

func add_member(member:Actor):
	members.append(member)
	member.team = self

func remove_member(member:Actor):
	members.erase(member)
	member.team = null

func get_members():
	return members

func get_average_location():
	var accumulated_position = Vector3.ZERO
	for actor in members:
		if is_instance_valid(actor):
			accumulated_position += actor.global_position
	return accumulated_position / members.size()

func get_average_health():
	var number_of_actors = members.size()
	var accumulated_health = 0
	for actor in members:
		if is_instance_valid(actor):
			accumulated_health += actor.health.current_health
	return accumulated_health / members.size()
