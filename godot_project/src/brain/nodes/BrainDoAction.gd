class_name classBrainDoAction
extends classBrainNode

var _action_name := ""
var _action_arguments := []

func set_action_name(v : String) -> void:
	_action_name = v

func set_action_arguments(v : Array) -> void:
	_action_arguments = v

func execute(_delta : float, brain_state) -> void:
	if not brain_state.actor:
		push_error("missing actor!")
		brain_state.pop_from_brain_stack(STATE.FAIL)
	if _action_name.empty():
		push_error("action name is empty!")
		brain_state.pop_from_brain_stack(STATE.FAIL)
	if not brain_state.actor.has_method(_action_name):
		push_error("action " + _action_name + " is missing in actor " + brain_state.actor.name + "!")
		brain_state.pop_from_brain_stack(STATE.FAIL)

		return
	brain_state.actor.callv(_action_name, _parse_arguments(brain_state, _action_arguments))
	brain_state.pop_from_brain_stack(STATE.SUCCESS)
