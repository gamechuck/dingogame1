class_name classBrainRepeat
extends classBrainNode

enum MODE { COUNT, FOREVER, CONDITION }

var _mode : int = MODE.FOREVER

var _count := 1

var _condition_name := ""
var _condition_arguments := []
var _not := false

var _child_node : classBrainNode = null

func set_mode(v : int) -> void:
	_mode = v

func set_count(v : int) -> void:
	_count = v

func set_condition_name(v : String) -> void:
	_condition_name = v

func set_condition_arguments(v : Array) -> void:
	_condition_arguments = v

func set_not(v : bool) -> void:
	_not = v

func get_metadata(_metadata := {}) -> Dictionary:
	return .get_metadata(
		{
			"current_count": 0,
		}
	)

func execute(delta : float, brain_state) -> void:
	assert(get_child_count() == 1)

	var metadata : Dictionary = brain_state.get_last_metadata()

	match metadata["state"]:
		STATE.FAIL, STATE.SUCCESS:
			match _mode:
				MODE.COUNT:
					metadata["current_count"] = 0
					metadata["state"] = STATE.ACTIVE
					brain_state.push_to_stack_and_execute(get_child(0), get_child(0).get_metadata(), delta)
				MODE.FOREVER:
					metadata["state"] = STATE.ACTIVE
					brain_state.push_to_stack_and_execute(get_child(0), get_child(0).get_metadata(), delta)
				MODE.CONDITION:
					if not brain_state.actor or _condition_name.empty() or not brain_state.actor.has_method(_condition_name):
						brain_state.pop_from_brain_stack(STATE.FAIL)

					metadata["state"] = STATE.ACTIVE
					execute(delta, brain_state)

		STATE.ACTIVE:
			match _mode:
				MODE.COUNT:
					if brain_state.last_node_state == STATE.SUCCESS:
						metadata["current_count"] += 1
						if metadata["current_count"] == _count:
							brain_state.pop_from_brain_stack(STATE.SUCCESS)
							return
					brain_state.push_to_stack_and_execute(get_child(0), get_child(0).get_metadata(), delta)
				MODE.FOREVER:
					brain_state.push_to_stack_and_execute(get_child(0), get_child(0).get_metadata(), delta)
				MODE.CONDITION:
					if brain_state.actor.callv(_condition_name, _parse_arguments(brain_state, _condition_arguments)):
						if _not:
							brain_state.push_to_stack_and_execute(get_child(0), get_child(0).get_metadata(), delta)
						else:
							brain_state.pop_from_brain_stack(STATE.SUCCESS)
					else:
						if _not:
							brain_state.pop_from_brain_stack(STATE.SUCCESS)
						else:
							brain_state.push_to_stack_and_execute(get_child(0), get_child(0).get_metadata(), delta)
