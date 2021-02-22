class_name classBrainState
extends Node

# holds dictionaries with 2 elements: reference to brain node, and its metadata
# dicts get pushed when new brain node is entered, and popped when brain node returns some result
var _brain_stack := []

# person that owns this brain
# (owner keyword is reserved!)
var actor : Node2D = null

# this gets set from brain nodes and read by brain state
var last_node_state : int = classBrainNode.STATE.FAIL

func clear_and_add_new_brain(brain : classBrainNode, new_actor : Node2D) -> void:
	clear()
	setup(brain, new_actor)

# cleans up everything
func clear() -> void:
	_brain_stack.clear()
	actor = null
	last_node_state = classBrainNode.STATE.FAIL

# sets everything up
func setup(brain : classBrainNode, new_actor : Node2D) -> void:
	push_to_brain_stack(brain, brain.get_metadata())
	actor = new_actor

# call this every time you want the brain to tick
func execute(delta : float) -> void:
	var _brain_node_data : Dictionary = _brain_stack.back()
	_brain_node_data["node"].execute(delta, self)

# returns metadata of last brain node pushed to stack
func get_last_metadata() -> Dictionary:
	return _brain_stack.back()["metadata"]

func push_to_brain_stack(node : classBrainNode, metadata : Dictionary) -> void:
	_brain_stack.push_back({"node": node, "metadata": metadata})

func pop_from_brain_stack(state : int) -> void:
	_brain_stack.pop_back()
	last_node_state = state

func push_to_stack_and_execute(node : classBrainNode, metadata : Dictionary, delta : float) -> void:
	push_to_brain_stack(node, metadata)
	node.execute(delta, self)
