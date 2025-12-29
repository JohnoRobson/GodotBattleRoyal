class_name StateEvaluationMemory

var _max_number_of_evaluation_frames: int = 5
## _state_evaluations is an Array[Array[StateEvaluation]]
var _state_evaluations: Array[Array]

func _init(number_of_evaluation_frames_to_store: int) -> void:
	assert(number_of_evaluation_frames_to_store > 0)
	_max_number_of_evaluation_frames = number_of_evaluation_frames_to_store

func push_evaluations(evaluation: Array[StateEvaluation]) -> void:
	assert(evaluation != null)
	_state_evaluations.append(evaluation)
	if _state_evaluations.size() > _max_number_of_evaluation_frames:
		_state_evaluations.pop_front()

func get_all_evaluations() -> Array[Array]:
	return _state_evaluations

func get_last_evaluation() -> Array[StateEvaluation]:
	return _state_evaluations.back()
