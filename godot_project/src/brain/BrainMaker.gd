class_name classBrainMaker
extends Node

onready var _brain_owners : Node = $BrainOwners

var brains_dict := {}
var _brains_data : Dictionary

func make_brains() -> int:
	var brain_owner_names := _brains_data.keys()
	for brain_owner_name in brain_owner_names:
		var brain_owner := Node.new()
		_brain_owners.add_child(brain_owner)
		brain_owner.name = brain_owner_name

		brains_dict[brain_owner_name] = {}

		var brain_owner_data : Dictionary = _brains_data[brain_owner_name]
		var brain_types : Array = brain_owner_data.keys()
		for brain_type in brain_types:
			if (brain_type as String).begins_with("."): continue

			var brain_type_data : Dictionary = brain_owner_data[brain_type]
			var brain_data : Dictionary = brain_type_data["brain"]
			var brain_container := Node.new()
			brain_owner.add_child(brain_container)
			brain_container.name = brain_type
			var brain : classBrainNode = make_brain(brain_data)
#			brain.name = brain_type + " - " + brain.name
			brain_container.add_child(brain)
			brains_dict[brain_owner_name][brain_type] = brain
	return OK

func clear_brains() -> void:
	for brain_owner in _brain_owners.get_children():
		_brain_owners.remove_child(brain_owner)
		brain_owner.queue_free()

func make_brain(brain_data : Dictionary) -> classBrainNode:
	var _brain : classBrainNode

	_brain = _build_brain_node_recursive(brain_data)

	return _brain

func _build_brain_node_recursive(node_data : Dictionary) -> classBrainNode:
	var node
	Logger.log("BRAIN_BUILDING", "building node " + node_data["type"])

	match node_data["type"]:
		"REPEAT":
			node = classBrainRepeat.new()
			node.name = "Repeat"

			var rules_defined := false
			if node_data.has("forever") and node_data["forever"]:
				node.set_mode(node.MODE.FOREVER)
				rules_defined = true
			elif node_data.has("count"):
				node.set_mode(node.MODE.COUNT)
				node.set_count(node_data["count"])
				rules_defined = true
			elif node_data.has("condition_name"):
				node.set_mode(node.MODE.CONDITION)
				if node_data.has("condition_name"):
					node.set_condition_name(node_data["condition_name"])
				else:
					push_warning("REPEAT node is missing condition_name! no condition will be checked for")
				if node_data.has("condition_arguments"):
					node.set_condition_arguments(node_data["condition_arguments"])
				else:
					push_warning("REPEAT node is missing condition_arguments! function might fail (if there are none, provide empty list)")
				if node_data.has("not"):
					node.set_not(node_data["not"])

				rules_defined = true

			if not rules_defined:
				push_warning("REPEAT node is missing minimum repetition rules definition! using defaults...")

			if node_data.has("child"):
				var child_data : Dictionary = node_data["child"]
				node.add_child(_build_brain_node_recursive(child_data), true)
			else:
				push_warning("REPEAT node has no child!")

		"SEQUENCE":
			node = classBrainSequence.new()
			node.name = "Sequence"

			if node_data.has("on_child_success"):
				node.set_on_child_success(node_data["on_child_success"])
			if node_data.has("on_child_fail"):
				node.set_on_child_fail(node_data["on_child_fail"])
			if node_data.has("on_end"):
				node.set_on_end(node_data["on_end"])

			if node_data.has("children"):
				for child_data in node_data["children"]:
					node.add_child(_build_brain_node_recursive(child_data), true)
			else:
				push_warning("SEQUENCE node has no children!")

		"DO_ACTION":
			node = classBrainDoAction.new()
			node.name = "DoAction"

			if node_data.has("action_name"):
				node.set_action_name(node_data["action_name"])
			else:
				push_warning("DO_ACTION node is missing action_name! no action will be executed")
			if node_data.has("action_arguments"):
				node.set_action_arguments(node_data["action_arguments"])
			else:
				push_warning("DO_ACTION node is missing action_arguments! function might fail (if there are none, provide empty list)")

		"WAIT_FOR":
			node = classBrainWaitFor.new()
			node.name = "WaitFor"

			if node_data.has("condition_name"):
				node.set_condition_name(node_data["condition_name"])
			else:
				push_warning("WAIT_FOR node is missing condition_name! no condition will be checked for")
			if node_data.has("condition_arguments"):
				node.set_condition_arguments(node_data["condition_arguments"])
			else:
				push_warning("WAIT_FOR node is missing condition_arguments! function might fail (if there are none, provide empty list)")

		"CHECK_CONDITION":
			node = classBrainCheckCondition.new()
			node.name = "CheckCondition"

			if node_data.has("condition_name"):
				node.set_condition_name(node_data["condition_name"])
			else:
				push_warning("CHECK_CONDITION node is missing condition_name! no condition will be checked for")
			if node_data.has("condition_arguments"):
				node.set_condition_arguments(node_data["condition_arguments"])
			else:
				push_warning("CHECK_CONDITION node is missing condition_arguments! function might fail (if there are none, provide empty list)")
			if node_data.has("not"):
				node.set_not(node_data["not"])

		"WAIT":
			node = classBrainWait.new()
			node.name = "Wait"

			if node_data.has("duration"):
				node.set_duration(node_data["duration"])
			else:
				push_warning("WAIT node is missing duration! using defaults...")

			if node_data.has("random"):
				node.set_duration_random(node_data["random"])

	return node

func load_brainsJSON() -> int:
	_brains_data = Flow.load_JSON(Flow.PATH_DATA_BRAINS)

	return OK
