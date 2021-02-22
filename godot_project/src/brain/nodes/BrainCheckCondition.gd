class_name classBrainCheckCondition
extends classBrainNode

var _condition_name := ""
var _condition_arguments := []
var _not := false

func set_condition_name(v : String) -> void:
	_condition_name = v

func set_condition_arguments(v : Array) -> void:
	_condition_arguments = v

func set_not(v : bool) -> void:
	_not = v

func execute(_delta : float, brain_state) -> void:
	if not brain_state.actor or _condition_name.empty() or not brain_state.actor.has_method(_condition_name):
		brain_state.pop_from_brain_stack(STATE.FAIL)

	if brain_state.actor.callv(_condition_name, _parse_arguments(brain_state, _condition_arguments)):
		if _not:
			brain_state.pop_from_brain_stack(STATE.FAIL)
		else:
			brain_state.pop_from_brain_stack(STATE.SUCCESS)
	else:
		if _not:
			brain_state.pop_from_brain_stack(STATE.SUCCESS)
		else:
			brain_state.pop_from_brain_stack(STATE.FAIL)
