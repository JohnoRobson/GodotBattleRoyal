class_name StateEvaluation

var state: State
var score: float

func _init(for_state: State, with_score: float) -> void:
	self.state = for_state
	self.score = with_score
