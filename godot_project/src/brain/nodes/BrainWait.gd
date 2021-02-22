class_name classBrainWait
extends classBrainNode

var _duration := 1.0
var _duration_random := 0.0

var _actual_duration := 0.0

func get_metadata(_metadata := {}) -> Dictionary:
	return .get_metadata(
		{
			"_current_time": 0.0,
			"_actual_duration": 0.0,
		}
	)

func set_duration(v : float) -> void:
	_duration = v

func set_duration_random(v : float) -> void:
	_duration_random = v

func execute(delta : float, brain_state) -> void:
	var metadata : Dictionary = brain_state.get_last_metadata()

	match metadata["state"]:
		STATE.FAIL, STATE.SUCCESS:
			metadata["current_time"] = 0.0
			metadata["actual_duration"] = _duration + rand_range(0.0, _duration_random)
			metadata["state"] = STATE.ACTIVE
		STATE.ACTIVE:
			metadata["current_time"] += delta
			if metadata["current_time"] >= metadata["actual_duration"]:
				brain_state.pop_from_brain_stack(STATE.SUCCESS)
