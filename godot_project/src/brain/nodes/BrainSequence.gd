class_name classBrainSequence
extends classBrainNode

enum ACTION { CONTINUE, RETURN_SUCCESS, RETURN_FAIL }

var _on_child_success = ACTION.CONTINUE
var _on_child_fail = ACTION.RETURN_FAIL
var _on_end = ACTION.RETURN_SUCCESS

func set_on_child_success(v : int) -> void:
	assert(v in ACTION.values())

	_on_child_success = v

func set_on_child_fail(v : int) -> void:
	assert(v in ACTION.values())

	_on_child_fail = v

func set_on_end(v : int) -> void:
	assert(v == ACTION.RETURN_SUCCESS or v == ACTION.RETURN_FAIL)

	_on_end = v

func get_metadata(_metadata := {}) -> Dictionary:
	return .get_metadata(
		{
			"current_node_idx": 0,
		}
	)

func execute(delta : float, brain_state) -> void:
	assert(get_child_count() > 0)

	var metadata : Dictionary = brain_state.get_last_metadata()

	match metadata["state"]:
		STATE.FAIL, STATE.SUCCESS:
			metadata["current_node_idx"] = 0
			_execute_current_node(delta, brain_state, metadata)
			metadata["state"] = STATE.ACTIVE
		STATE.ACTIVE:
			match brain_state.last_node_state:
				STATE.ACTIVE:
					_execute_current_node(delta, brain_state, metadata)
				STATE.SUCCESS:
					match _on_child_success:
						ACTION.CONTINUE:
							_advance_node(delta, brain_state, metadata)
						ACTION.RETURN_SUCCESS:
							brain_state.pop_from_brain_stack(STATE.SUCCESS)
						ACTION.RETURN_FAIL:
							brain_state.pop_from_brain_stack(STATE.FAIL)
				STATE.FAIL:
					match _on_child_fail:
						ACTION.CONTINUE:
							_advance_node(delta, brain_state, metadata)
						ACTION.RETURN_SUCCESS:
							brain_state.pop_from_brain_stack(STATE.SUCCESS)
						ACTION.RETURN_FAIL:
							brain_state.pop_from_brain_stack(STATE.FAIL)

func _advance_node(delta, brain_state, metadata) -> void:
	metadata["current_node_idx"] += 1
	if metadata["current_node_idx"] == get_child_count():
		# end reached
		match _on_end:
			ACTION.RETURN_SUCCESS:
				brain_state.pop_from_brain_stack(STATE.SUCCESS)
			ACTION.RETURN_FAIL:
				brain_state.pop_from_brain_stack(STATE.FAIL)
	else:
		_execute_current_node(delta, brain_state, metadata)

func _execute_current_node(delta, brain_state, metadata) -> void:
	var _current_node = get_child(metadata["current_node_idx"])
	brain_state.push_to_brain_stack(_current_node, _current_node.get_metadata())
	_current_node.execute(delta, brain_state)
