class_name NameGenerator extends Object

var adjectives = [
	"Active",
	"Brutal",
	"Callous",
	"Dainty",
	"Elegant",
	"Fast",
	"Gaudy",
	"Hardy",
	"Ignorant",
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
	"Utmost",
	"Valiant",
	"Waning",
	"Yappy",
	"Zesty"
]

var nouns = [
	"Actor",
	"Baker",
	"Chef",
	"Doctor",
	"Engineer",
	"Farmer",
	"Guide",
	"Harpist",
	"Intern",
	"Janitor",
	"Kinesiologist",
	"Lawyer",
	"Manager",
	"Nurse",
	"Optician",
	"Pilot",
	"Quarterback",
	"Reporter",
	"Sailor",
	"Tailor",
	"Undertaker",
	"Vlogger",
	"Waiter",
	"Yodeler",
	"Zookeeper"
]

func generate_team_name() -> String:
	var adjective = adjectives.pick_random()
	var noun = nouns.pick_random()
	return "Team %s %ss" % [adjective, noun]
