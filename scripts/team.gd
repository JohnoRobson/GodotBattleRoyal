class_name Team extends Node

@onready var members: Array[Actor] = []

func add_member(new_member:Actor):
	members.append(new_member)
	new_member.team = self

func get_members():
	return members
