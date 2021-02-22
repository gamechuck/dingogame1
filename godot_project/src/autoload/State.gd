
# State is an autoload script that contains all global state variables.
# Everything here will be saved to the "context" in user://.
# Best to ask for more information if anything is unclear!
extends Node

################################################################################
## CONSTANTS

const SCENE_TOWN_STATE := preload("res://src/autoload/state/TownState.gd")

enum GAME_STATE { WIN, LOSE }
enum DAY_STATE { DAWN, DAY, DUSK, NIGHT }

################################################################################
## SIGNALS

signal game_state_changed # new_state
# warning-ignore:unused_signal
signal npc_count_alive_changed
#signal player_overlay_update_requested
# warning-ignore:unused_signal
signal day_phase_updated
# warning-ignore:unused_signal
signal day_phase_time_updated
# warning-ignore:unused_signal
signal day_time_updated


################################################################################
## PUBLIC VARIABLES
# This can be private function since nobody is calling it from outside
var game_state := -1 setget set_game_state
func set_game_state(v : int) -> void:
	game_state = v
#	_can_update_day_phase = false
	emit_signal("game_state_changed", game_state)

# public reference to CaseManager
#onready var case_manager : classCaseManager = $CaseManager

# Called from Town.gd
var loaded_town : classTown setget set_loaded_town
func set_loaded_town(v : classTown) -> void:
	loaded_town = v
#	_can_update_day_phase = true
#	current_day_phase = loaded_town.town_state.day_phase_state.get("starting_phase")
#	_day_phase_duration = loaded_town.town_state.day_phase_state.get("day_phase_duration")
#	_night_phase_duration = loaded_town.town_state.day_phase_state.get("night_phase_duration")
#	_dawn_duration = _day_phase_duration * clamp(loaded_town.town_state.day_phase_state.get("dawn_duration_ratio"), 0.0, 1.0)
#	_dusk_duration = _night_phase_duration * clamp(loaded_town.town_state.day_phase_state.get("dusk_duration_ratio"), 0.0, 1.0)
#	_current_day_phase_time = 0.0
#	_current_day_time = 0.0
#	connect("day_phase_updated", loaded_town, "_on_day_phase_updated")
#	connect("day_phase_updated", loaded_town.get_player(), "_on_day_phase_updated")
#	emit_signal("npc_count_alive_changed")
#	emit_signal("day_phase_updated", current_day_phase)

# current town ID
#var town_id := "town_01"

# all classTownStates created from Towns JSON from Flow
#var town_states := {}
#
#var current_day_phase : int = DAY_STATE.DAY setget , get_current_day_phase
#func get_current_day_phase() -> int:
#	return current_day_phase
#
#var _dawn_duration := 0.0 setget , get_dawn_duration
#func get_dawn_duration() -> float:
#	return _dawn_duration
#
#var _dusk_duration := 0.0 setget , get_dusk_duration
#func get_dusk_duration() -> float:
#	return _dusk_duration


################################################################################
## PRIVATE VARIABLES

#var _can_update_day_phase := false
#var _day_phase_duration := 1.0 # in milliseconds
#var _night_phase_duration := 1.0 # in milliseconds
#var _current_day_time := 0.0
#var _current_day_phase_time := 0.0
##var _update_idle_time := 2.0
#
#################################################################################
### GODOT CALLBACKS
#
func _ready() -> void:
	# If it doesn't exist, create the saves-folder in user://
	var dir : Directory = Directory.new()
	if not dir.dir_exists(Flow.SAVE_FOLDER):
		print("Creating saves-folder at '{0}' (First-time initialization).".format([Flow.SAVE_FOLDER]))
		var error : int = dir.make_dir(Flow.SAVE_FOLDER)
		if error != OK:
			push_error("Failed to create saves-folder due to error '{0}'.".format([error]))

################################################################################
## PUBLIC FUNCTIONS

# Called from Flow.gd -> load_settings()
# Load a previous State from a file defined in the user://saves-folder or the default one.
func load_stateJSON(path : String = Flow.DEFAULT_CONTEXT_PATH) -> int:
	var context : Dictionary = Flow.load_JSON(path)
	if not context.empty():
		load_state_from_context(context)
		return OK
	else:
		return ERR_FILE_CORRUPT

# Save the current State to the user://saves-folder.
func save_stateJSON(path : String = Flow.USER_SAVE_PATH) -> int:
	var context : Dictionary = save_state_to_context()
	return Flow.save_JSON(path, context)

## STATE

# Called from load_stateJSON() function when scene is loading
func load_state_from_context(_context : Dictionary):
	if ConfigData.verbose_mode:
		print("Loading state from the context...")

	# this if is necessary since this function gets called from Flow which is autoloaded before State
#	if case_manager:
#		case_manager.cases.clear()

#	town_states.clear()

#	town_id = context.get("town_id", town_id)

#	init_towns()
#	for town_context in context.get("towns", []):
#		set_town_from_context(town_context)

func save_state_to_context() -> Dictionary:
	var context := {}

#	var context_dict := {
#		"towns": town_states.values()
#	}

#	context.town_id = town_id
#
#	for key in context_dict.keys():
#		context[key] = []
#		for context_owner in context_dict[key]:
#			var subcontext : Dictionary = context_owner.context
#			if not subcontext.empty():
#				context[key].append(subcontext)

	return context

## TOWNS

# This function is responsible for reading towns data (setup from json file) in Flow.gd and create dict of TownsState objects.
#func init_towns() -> void:
#	for data in Flow.town_data:
#		var ts := SCENE_TOWN_STATE.new()
#		ts.id = data.get("id", "MISSING ID")
#		ts.set_day_state(data.get("day_phases", ""))
#
#		if ConfigData.verbose_mode:
#			print("Adding registered town_states with id '{0}' to State!".format([data.get("id", "MISSING ID")]))
#		town_states[ts.id] = ts

#func set_town_from_context(town_context : Dictionary) -> void:
#	if town_context.has("id"):
#		var _town_id = town_context.id
#		if town_states.has(_town_id):
#			town_states[_town_id].context = town_context
#
#func set_town_completed(_town_id : String, completed : bool):
#	if town_states.has(_town_id):
#		town_states[_town_id].completed = completed

# Can be called from various places to get town state data
#func get_town_state_by_id(_town_id : String):
#	if not town_states.has(_town_id):
#		push_error("Town state with id '{0}' is not available in the State!".format([_town_id]))
#		return null
#	else:
#		return town_states[_town_id]
#
#func get_npc_groups_alive() -> Dictionary:
#	var ts : classTownState = get_town_state_by_id(town_id)
#	return ts.npc_groups_alive
#
#func set_next_level() -> void:
#	var found = false
#	for state in town_states.values():
#		if not found and state.id == town_id:
#			found = true
#		elif found:
#			town_id = state.id
#			break
#
#func has_next_level() -> bool:
#	var found = false
#	var town_states_values = town_states.values()
#	for state in  town_states_values:
#		if not found and state.id == town_id:
#			found = true
#			continue
#		elif found and state:
#			return true
#	return false

#func reset_town_state():
#	case_manager.cases.clear()
#
#func set_quick_start_level() -> void:
#	town_id = "town_01"

################################################################################
## SIGNAL CALLBACKS

func _on_game_won() -> void:
	set_game_state(GAME_STATE.WIN)

func _on_game_lost() -> void:
	set_game_state(GAME_STATE.LOSE)

# TODO: Actually the player's HP, etc should be saved here in a sort of PlayerState.gd
# In a similar way to the TownState.gd (maybe even INSIDE the townstate?)
# This would also get rid of having to push ALL the arguments...
#func _on_player_overlay_update_requested(value : int, is_attacking := false, is_running := false) -> void:
#	emit_signal("player_overlay_update_requested", value, is_attacking, is_running)
#
#func _on_npc_count_alive_changed() -> void:
#	emit_signal("npc_count_alive_changed")
