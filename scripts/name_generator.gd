class_name NameGenerator extends Object

# One for each letter, missing A I U V X Y
var adjectives = [
	"Brutal",
	"Callous",
	"Dainty",
	"Elegant",
	"Fast",
	"Gaudy",
	"Hardy",
	"Jolly",
	"Klutzy",
	"Lanky",
	"Mega",
	"Nasty",
	"Old",
	"Pointy",
	"Queasy",
	"Ragged",
	"Stoic",
	"Tainted",
	"Waning",
	"Zesty"
]

# One for each letter, missing I K L M N O P Q R S U X Y Z
var nouns = [
	"Arborist",
	"Botanist",
	"Coroner",
	"Dentist",
	"Entomologist",
	"Ferrier",
	"Guard",
	"Heckler",
	"Jailer",
	"Teacher",
	"Vlogger",
	"Wanderer"
]

func generate_team_name() -> String:
	var adjective = adjectives.pick_random()
	var noun = nouns.pick_random()
	return "%s %ss" % [adjective, noun]
