class_name classCase
extends Reference

var type : String
var target : Node2D
var investigations := []
var closed := false

func has_investigation(investigator : Node2D) -> bool:
	for investigation in investigations:
		if investigation.investigator_name == investigator.name and not investigation.closed:
			return true
	return false

func has_closed_investigation(investigator : Node2D) -> bool:
	for investigation in investigations:
		if investigation.investigator_name == investigator.name and investigation.closed:
			return true
	return false

func get_investigation(investigator : Node2D) -> classInvestigation:
	for investigation in investigations:
		if investigation.investigator_name == investigator.name:
			return investigation
	return null

func open_investigation(investigator : Node2D, location : Vector2) -> void:
	# first check if we closed it already; if we have, ignore it
	if has_closed_investigation(investigator):
		return

	var investigation := classInvestigation.new()
	investigation.case_type = type
	investigation.timestamp = OS.get_ticks_msec()
	investigation.investigator_name = investigator.name
	investigation.location = location
	investigations.append(investigation)
	Logger.log("CASE", "investigation in case " + type + " by " + investigator.name + " opened!")

func mark_target_as_investigated(investigator : Node2D) -> void:
	for investigation in investigations:
		if investigation.investigator_name == investigator.name:
			# actions on closing investigation
			if target is classCharacter:
				(target as classCharacter).investigated = true

func close_investigation(investigator : Node2D) -> void:
	for investigation in investigations:
		if investigation.investigator_name == investigator.name:
			investigation.closed = true

	Logger.log("CASE", "investigation in case " + type + " by " + investigator.name + " closed!")
	_update_closed()

func _update_closed() -> void:
	for investigation in investigations:
		if not investigation.closed:
			return
	# all investigations are closed!
	closed = true
