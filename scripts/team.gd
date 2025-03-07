class_name Team extends Node

@onready var members: Array[Actor] = []

var display_name: String

func _init():
	var name_generator = NameGenerator.new()
	display_name = name_generator.generate_team_name()

func add_member(new_member:Actor):
	members.append(new_member)
	new_member.team = self

func get_members():
	return members
