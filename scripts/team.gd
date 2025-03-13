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
