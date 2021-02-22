class_name classBrainWaitFor
extends classBrainNode

var _condition_name := ""
var _condition_arguments := []

func set_condition_name(v : String) -> void:
	_condition_name = v

func set_condition_arguments(v : Array) -> void:
	_condition_arguments = v

func execute(_delta : float, brain_state) -> void:
	var metadata : Dictionary = brain_state.get_last_metadata()

	if not brain_state.actor or _condition_name.empty() or not brain_state.actor.has_method(_condition_name):
		brain_state.pop_from_brain_stack(STATE.FAIL)

	metadata["state"] = STATE.ACTIVE

	if brain_state.actor.callv(_condition_name, _parse_arguments(brain_state, _condition_arguments)):
		brain_state.pop_from_brain_stack(STATE.SUCCESS)
