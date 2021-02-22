class_name classCaseManager
extends Node

# list of cases
var cases := []

# custom case sorter, by priority
class case_sorter:
	static func sort(a : classCase, b : classCase):
		var a_priority : int = Flow.cases_data[a.type]["priority"]
		var b_priority : int = Flow.cases_data[b.type]["priority"]
		if a_priority > b_priority:
			return false
		return true

################################################################################
## PUBLIC FUNCTIONS

# makes new case and appends investigation to it, if case doesn't exist;
# appends investigation to case if case already exists;
# updates investigation if case and investigation already exist
func open_investigation(investigator : Node2D, type : String, target : Node2D, location : Vector2) -> void:
	# check if case already exists
	for i in cases.size():
		var case : classCase = cases[i]
		if case.type == type and case.target == target:
			# case exists!
			# is it the same investigator?
			if case.has_investigation(investigator):
				# yes; update investigation
				var investigation : classInvestigation = case.get_investigation(investigator)
				investigation.timestamp = OS.get_ticks_msec()
				investigation.location = location
			else:
				# no; make new investigation
				case.open_investigation(investigator, location)
			return
	# case doesn't exist
	# check if case type is valid
	if not type in Flow.cases_data.keys():
		push_error("case type " + type + " does not exist!")
		return
	# create new case
	var case := _open_case(type, target)
	case.open_investigation(investigator, location)

# closes given investigation for case, and closes and removes case if it was final investigation
func close_investigation(investigator : Node2D, type : String, target : Node2D) -> void:
	# check if case exists
	for i in cases.size():
		var case : classCase = cases[i]
		if case.type == type and case.target.name == target.name:
			# case exists!
			# check if investigation exists
			if case.has_investigation(investigator):
				case.close_investigation(investigator)
			else:
				push_error("cannot find investigation in case!")
				return
			_remove_closed_cases()
			return
		else:
#			push_error("cannot find case of type " + type + " with target " + target.name + "!")
			return
	# no case exists
	push_error("cannot find case of type " + type + "!")
	return

# same as close_investigation, but target is gives by name instead of reference
func close_investigation_by_type(investigator : Node2D, type : String, target_name : String) -> void:
	# check if case exists
	for i in cases.size():
		var case : classCase = cases[i]
		if case.type == type and case.target.name == target_name:
			# case exists!
			# check if investigation exists
			if case.has_investigation(investigator):
				case.close_investigation(investigator)
			else:
				continue
			_remove_closed_cases()
			return
		else:
			continue
	# no case exists
	push_error("cannot find case of type " + type + "!")
	return

func mark_target_as_investigated_by_type(investigator : Node2D, type : String, target_name : String) -> void:
	# check if case exists
	for i in cases.size():
		var case : classCase = cases[i]
		if case.type == type and case.target.name == target_name:
			# case exists!
			# check if investigation exists
			if case.has_investigation(investigator):
				case.mark_target_as_investigated(investigator)
			else:
				continue
			_remove_closed_cases()
			return
		else:
			continue
	# no case exists
	push_error("cannot find case of type " + type + "!")
	return

# since NPC investigates top priority case, that one gets found and closed
func close_top_investigation(investigator : Node2D) -> void:
	var case : classCase = get_case(investigator)
	close_investigation(investigator, case.type, case.target)

# usually called when NPC dies
func close_all_investigations(investigator : Node2D) -> void:
	for case in cases:
		case.close_investigation(investigator)
	_remove_closed_cases()

func is_investigating_any_case(investigator : Node2D) -> bool:
	for case in cases:
		if case.has_investigation(investigator):
			return true
	return false

func get_case(investigator : Node2D) -> classCase:
	for case in cases:
		if case.has_investigation(investigator):
			return case
	return null

func get_case_by_type(type : String, target_name : String) -> classCase:
	for case in cases:
		if case.type == type and case.target.name == target_name:
			return case
	return null

func get_investigation(investigator : Node2D) -> classInvestigation:
	for case in cases:
		if case.has_investigation(investigator):
			return case.get_investigation(investigator)
	return null

func clear_all_cases() -> void:
	cases.clear()

################################################################################
## PRIVATE FUNCTIONS

func _open_case(type : String, target : Node2D) -> classCase:
	var case := classCase.new()
	case.type = type
	case.target = target
	cases.append(case)
	_sort_cases()
	Logger.log("CASE", "case (" + type + " - " + target.name + ") opened!")
	return case

func _remove_closed_cases() -> void:
	for i in range(cases.size() - 1, -1, -1):
		var case : classCase = cases[i]
		if case.closed:
			# also mark target as investigated and do other stuff to targets
			var target : Node2D = case.target
			if target is classBell:
				(target as classBell).set_active(false)

			Logger.log("CASE", "case (" + case.type + " - " + case.target.name + ") closed!")
			cases.remove(i)

func _sort_cases() -> void:
	cases.sort_custom(case_sorter, "sort")
