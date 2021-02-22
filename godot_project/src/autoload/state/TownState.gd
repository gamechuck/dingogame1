class_name classTownState
extends Reference

const DEFAULT_THUMBNAIL_TEXTURE := "res://ndh-assets/UI/thumbnails/thumbnail.png"
#
#var id := ""
#var completed := false
#var in_progress := false
#var npc_groups := {}
#var player_state := {}
#
##var day_phase_state := {} setget set_day_state
##func set_day_state(value : Dictionary) -> void:
##	day_phase_state = value
#
#var context : Dictionary setget set_context, get_context
#func set_context(value : Dictionary) -> void:
#	if not value.has("id"):
#		push_error("Mission context requires id!")
#
#	id = value.id
#	completed = value.get("completed", false)
#
##	npc_groups = value.get("npc_groups", {}).duplicate(true)
#	player_state = value.get("player", {}).duplicate(true)
#	pass
#
#func get_context() -> Dictionary:
	# Don't save the town if it is NOT in_progress nor completed!
#	if not completed and not in_progress:
#		return {}
#
#	var _context := {}
#	_context.id = id
#	if completed:
#		_context.completed = true
#	if in_progress:
#		_context.in_progress = true
#
#	_context.npc_groups = npc_groups
#
#	return _context

#var locked : bool setget , get_locked
#func get_locked():
#	# Check if the town is locked or unlocked depending on prereq!
#	var _prerequisites : Array = self.prerequisites
#	for town in State.town_states.values():
#		if town.id in _prerequisites and not town.completed:
#			return true
#	return false

## These are all constants derived from towns.JSON and should be treated as such!
#var name : String setget , get_name
#func get_name():
#	return Flow.get_town_data(id, "name", "MISSING NAME")
#
#var place_description : String setget , get_place_description
#func get_place_description():
#	return Flow.get_town_data(id, "place_description", "MISSING PLACE DESCRIPTION")
#
#var description : String setget , get_description
#func get_description():
#	return Flow.get_town_data(id, "description", "MISSING DESCRIPTION")
#
#var thumbnail_texture : String setget , get_thumbnail_texture
#func get_thumbnail_texture():
#	return Flow.get_town_data(id, "thumbnail_texture", DEFAULT_THUMBNAIL_TEXTURE)

#var prerequisites : Array setget , get_prerequisites
#func get_prerequisites():
#	return Flow.get_town_data(id, "prerequisites", [])
#
#var win_conditions : Array setget , get_win_conditions
#func get_win_conditions():
#	# The default is to kill all the npcs!
#	return Flow.get_town_data(id, "win_conditions", ["kill_all"])
#
#var packed_scene : String setget , get_packed_scene
#func get_packed_scene():
#	return Flow.get_town_data(id, "packed_scene", "res://src/game/towns/Town_01.tscn")
#
#var debug_level := false setget , get_is_debug_level
#func get_is_debug_level():
#	return Flow.get_town_data(id, "debug", false)

#func get_human_readable_conditions() -> Array:
#	var conditions := self.win_conditions
#	var human_readable_conditions := []
#
#	for condition in conditions:
#		match condition:
#			"kill_all":
#				human_readable_conditions.append("Kill all npcs")
#			"kill_mayor":
#				human_readable_conditions.append("Kill the Mayor")
#			_:
#				human_readable_conditions.append("UNKNOWN CONDITION")
#
#	return human_readable_conditions
