class_name classBrainNode
extends Node

# state a node can be in, and what gets returned to brain state
enum STATE { SUCCESS, FAIL, ACTIVE }

# returns metadata when requested; overriden by implemented nodes
func get_metadata(metadata := {}) -> Dictionary:
	metadata["state"] = STATE.FAIL
	return metadata

func execute(_delta : float, _brain_state) -> void:
	assert(false) # this makes sure we implement this function

# parses arguments if special variables were used
func _parse_arguments(brain_state, arguments : Array) -> Array:
	var parsed_arguments := []

	for argument in arguments:
		if argument is String and argument == "$TARGET":
			parsed_arguments.append(brain_state.actor.get_target())
		else:
			parsed_arguments.append(argument)

	return parsed_arguments
