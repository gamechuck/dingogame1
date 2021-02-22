extends Node

################################################################################
## CONSTANTS

enum STATE { STARTUP, MENU, GAME }

const DEFAULT_OPTIONS_PATH := "res://default_options.cfg"
# Settings are a subset of options that can be modified by the user.
const USER_SETTINGS_PATH := "user://user_settings.cfg"

const DEFAULT_CONTROLS_PATH := "res://default_controls.json"
const USER_CONTROLS_PATH := "user://user_controls.json"

const SAVE_FOLDER := "user://saves"

const DEFAULT_CONTEXT_PATH := "res://default_context.json"
const USER_SAVE_PATH := SAVE_FOLDER + "/user_save.json"

const PATH_DATA_BRAINS := "res://data/brains.jsonc"
const PATH_DATA_TOWNS := "res://data/towns.jsonc"
const PATH_DATA_CASES := "res://data/cases.jsonc"
const PATH_DATA_INTERACTABLES := "res://data/interactables.jsonc"
const PATH_DATA_PLAYER := "res://data/player.jsonc"
const PATH_DATA_NPCS := "res://data/npcs.jsonc"

const CURSOR_TEXTURE := preload("res://ndh-assets/UI/elements/cursor.png")
const CURSOR_PRESSED_TEXTURE := preload("res://ndh-assets/UI/elements/cursor_pressed.png")

################################################################################
## PUBLIC VARIABLES

# Is the game currently in editor mode? or not?
var is_in_editor_mode := false

# WHY is this an array? Towns need their order to be preserved!!!
var towns_data := []
var cases_data := {}
var interactable_data := {}
var player_data := {}
var npcs_data := {}

################################################################################
## PRIVATE VARIABLES

onready var _controls_loader := $ControlsLoader
onready var _data_loader := $DataLoader
onready var _brain_maker := $BrainMaker

var _game_flow := {
	"menu": {
		"packed_scene": preload("res://src/Menu.tscn"),
		"state": STATE.MENU
		},
	"game": {
		"packed_scene": preload("res://src/Game.tscn"),
		"state": STATE.GAME
		}
	}
var _game_state : int = STATE.STARTUP

################################################################################
## SIGNALS

signal pause_toggled

################################################################################
## GODOT CALLBACKS

func _ready():
	var _error := load_settings()
	if ConfigData.verbose_mode:
		print(
			"     _     _   _        _     ___                    _                       \n",
			" ___|_|___| |_| |_    _| |___|  _|___ ___ ___ ___   | |_ ___ ___ ___ ___ ___ \n",
			"|   | | . |   |  _|  | . | -_|  _| -_|   |  _| -_|  |   | -_|  _| . | -_|_ -|\n",
			"|_|_|_|_  |_|_|_|    |___|___|_| |___|_|_|___|___|  |_|_|___|_| |___|___|___|\n",
			"      |___|                                                                  \n"
		)
		# ASCII -> Rectangles
		print("version {0}.{1} ({2})".format([
			ConfigData.major_version,
			ConfigData.minor_version,
			ConfigData.version_string]))

# Catch all unhandled input not caught be any other control nodes.
func _unhandled_input(event : InputEvent):
	if InputMap.has_action("toggle_full_screen") and event.is_action_pressed("toggle_full_screen"):
		OS.window_fullscreen = not OS.window_fullscreen

	if InputMap.has_action("reload_all") and event.is_action_pressed("reload_all"):
		call_deferred("deferred_reload_current_scene", true)
	elif InputMap.has_action("reload_scene") and event.is_action_pressed("reload_scene"):
		call_deferred("deferred_reload_current_scene", false)

	match _game_state:
		STATE.GAME:
			if InputMap.has_action("toggle_paused") and event.is_action_pressed("toggle_paused"):
				emit_signal("pause_toggled")

################################################################################
## PUBLIC FUNCTIONS

# Called on scene loading
func load_settings() -> int:
	if ConfigData.verbose_mode:
		print("----- (Re)loading game settings from file -----")
	var _error : int = ConfigData.load_optionsCFG()
	_error += _controls_loader.load_controlsJSON()
	_error += _data_loader.load_dataJSON()
	_error += _brain_maker.load_brainsJSON()
	_brain_maker.clear_brains()
	_brain_maker.make_brains()

	# Also load the default context..
	# might autoload the user_context in the future here?
	_error += State.load_stateJSON()
	if _error == OK:
		if ConfigData.verbose_mode:
			print("----> Succesfully loaded settings!")
	else:
		push_error("Failed to load settings! Check console for clues!")
	return _error

# Quit the game during an idle frame.
func deferred_quit() -> void:
	get_tree().quit()

# It is now safe to reload the current scene.
func deferred_reload_current_scene(reload_all : bool = true) -> void:
	if reload_all:
		var _error := load_settings()

	var _error := get_tree().reload_current_scene()
	get_tree().paused = false

func change_scene_to(key : String) -> void:
	if _game_flow.has(key):
		var state_settings : Dictionary = _game_flow[key]
		var packed_scene : PackedScene = state_settings.packed_scene
		_game_state = state_settings.state

		var error := get_tree().change_scene_to(packed_scene)
		get_tree().paused = false
		if error != OK:
			push_error("Failed to change scene to '{0}'.".format([key]))
		else:
			if ConfigData.verbose_mode:
				print("Succesfully changed scene to '{0}'.".format([key]))
	else:
		push_error("Requested scene '{0}' was not recognized... ignoring call for changing scene.".format([key]))

## AI

#func get_brain(owner_name : String, state_name : String) -> classBrainNode:
#	var brain = _brain_maker.brains_dict[owner_name][state_name]
#	return brain
#
#func get_interrupts(owner_name : String, state_name : String) -> Array:
#	var owner_data : Dictionary = _brain_maker._brains_data[owner_name]
#	return owner_data[state_name]["interrupts"]
#
#func get_brain_state_data(owner_name : String, state_name : String) -> Dictionary:
#	var owner_data : Dictionary = _brain_maker._brains_data[owner_name]
#	var state_data : Dictionary = owner_data[state_name]
#	return state_data
#
#func get_default_brain_state_for(owner_name : String) -> String:
#	var owner_data : Dictionary = _brain_maker._brains_data[owner_name]
#	for state_name in owner_data.keys():
#		var state_data : Dictionary = owner_data[state_name]
#		if state_data.has("default") and state_data["default"] == true:
#			return state_name
#	push_warning("get_default_state_for(" + owner_name + ") -- couldn't find state with [\"default\": true] entry! using first state...")
#	return owner_data.keys()[0]
#


## CASE SYSTEM
#
#func get_case_priority(case_type : String) -> int:
#	if not cases_data.has(case_type):
#		push_error("case with type " + case_type + " does not exist in cases data!")
#		return -1
#
#	var case_data = cases_data[case_type]
#	return case_data["priority"]
#
#func get_case_weapon_needed(case_type : String) -> bool:
#	if not cases_data.has(case_type):
#		push_error("case with type " + case_type + " does not exist in cases data!")
#		return false
#
#	var case_data = cases_data[case_type]
#	return case_data["weapon_needed"]


## TOWN

func get_town_data(id : String, key : String, default):
	for data in towns_data:
		if data.get("id", "MISSING ID") == id:
			return data.get(key, default)

	return default

## UTIL SCRIPTS
# (move these to Util singleton?)
#
#func get_state_from_weighted_list(states : Dictionary) -> String:
#	var n := rand_range(0.0, 1.0)
#	var a := 0.0
#	for state in states.keys():
#		var b : float = states[state]
#		if a <= n and n < a + b:
#			return state
#		else:
#			a += b
#	return states.keys()[-1]

func get_closest_object(source : Node2D, objects : Array) -> Node2D:
	var source_position := source.global_position
	var closest_distance := INF
	var closest_object : Node2D = null

	for object in objects:
		var distance : float = object.global_position.distance_to(source_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_object = object

	return closest_object

func get_angle_difference(a : float, b : float) -> float:
	var diff = b - a
	diff = fmod2(diff + PI, TAU) - PI
	return diff

func angle_degrees_to_direction(angle_degrees : float) -> int:
	if angle_degrees >= 337.5 or angle_degrees < 22.5:
		return Global.DIRECTION.E
	elif angle_degrees >= 22.5 and angle_degrees < 67.5:
		return Global.DIRECTION.SE
	elif angle_degrees >= 67.5 and angle_degrees < 112.5:
		return Global.DIRECTION.S
	elif angle_degrees >= 112.5 and angle_degrees < 157.5:
		return Global.DIRECTION.SW
	elif angle_degrees >= 157.5 and angle_degrees < 202.5:
		return Global.DIRECTION.W
	elif angle_degrees >= 202.5 and angle_degrees < 247.5:
		return Global.DIRECTION.NW
	elif angle_degrees >= 247.5 and angle_degrees < 292.5:
		return Global.DIRECTION.N
	elif angle_degrees >= 292.5 and angle_degrees < 337.5:
		return Global.DIRECTION.NE
	return 0

func angle_to_direction(angle : float) -> int:
	return angle_degrees_to_direction(rad2deg(angle))

# special kind of mod, used for get_angle_difference above
# (doesn't return same sign as dividend)
func fmod2(a : float, n : float) -> float:
	return a - floor(a / n) * n

## STATIC FUNCTIONS

static func load_JSON(path : String) -> Dictionary:
	var file : File = File.new()
	var error : int = file.open(path, File.READ)
	if error == OK:
		var text : String = file.get_as_text()
		file.close()
		text = JSONMinifier.minify_json(text)
		var parse_result = parse_json(text)
		if parse_result is Dictionary:
			return parse_result
		elif parse_result is Array:
			push_error("Top-level arrays in JSON are not allowed! (@ '{0}')".format([path]))
		else:
			push_error("Failed to correctly process '{0}', check file format!".format([path]))
		return {}
	else:
		push_error("Failed to open '{0}', check file availability!".format([path]))
		return {}

# Save a dictionary, in JSON format, to a file.
static func save_JSON(path : String, dictionary : Dictionary) -> int:
	var file : File = File.new()
	var error : int = file.open(path, File.WRITE)
	if error == OK:
		var text : String = to_json(dictionary)
		text = JSONBeautifier.beautify_json(text)
		file.store_string(text)
		file.close()

		print("Succesfully saved '{0}'.".format([path]))
		return OK
	else:
		push_error("Could not open file for writing purposes '{0}', check if file is locked!".format([path]))
		return error

# Load a TXT-file and return it as a string.
static func load_TXT(path : String) -> String:
	var file : File = File.new()
	var string : String = ""
	var error : int = file.open(path, File.READ)
	if error == OK:
		string = file.get_as_text()
		file.close()
		return string
	else:
		push_error("Failed to open '{0}', check file availability!".format([path]))
		return ""
