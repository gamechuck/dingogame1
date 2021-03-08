extends Node


################################################################################
## CONSTANTS

enum STATE { STARTUP, MENU, GAME }

const DEFAULT_CONTROLS_PATH := "res://default_controls.json"
const USER_CONTROLS_PATH := "user://user_controls.json"

const SAVE_FOLDER := "user://saves"
const USER_SAVE_PATH := SAVE_FOLDER + "/user_save.json"

const DATA_PATH := "res://data/game_data.jsonc"


################################################################################
## PUBLIC VARIABLES
var game_data := {}
var player_data := {}
var layer_data := {}


################################################################################
## PRIVATE VARIABLES
onready var _controls_loader := $ControlsLoader
onready var _data_loader := $DataLoader

var _game_flow := {
	"menu": {
		"packed_scene": load("res://src/Menu.tscn"),
		"state": STATE.MENU
		},
	"game": {
		"packed_scene": load("res://src/Game.tscn"),
		"state": STATE.GAME
		}
	}
var _game_state : int = STATE.STARTUP



################################################################################
## GODOT CALLBACKS

func _ready():
	# If it doesn't exist, create the saves-folder in user://
	var dir : Directory = Directory.new()
	if not dir.dir_exists(Flow.SAVE_FOLDER):
		print("Creating saves-folder at '{0}' (First-time initialization).".format([Flow.SAVE_FOLDER]))
		var error : int = dir.make_dir(Flow.SAVE_FOLDER)
		if error != OK:
			push_error("Failed to create saves-folder due to error '{0}'.".format([error]))
	load_settings()

################################################################################
## PUBLIC FUNCTIONS

# Called on scene loading
func load_settings() -> void:
	if ConfigData.verbose_mode:
		print("----- (Re)loading game settings from file -----")
	#ConfigData.load_optionsCFG()
	_controls_loader.load_controlsJSON()
	_data_loader.load_dataJSON()

# Quit the game during an idle frame.
func deferred_quit() -> void:
	get_tree().quit()

# It is now safe to reload the current scene.
func deferred_reload_current_scene(reload_all : bool = true) -> void:
	if reload_all:
		load_settings()

	get_tree().reload_current_scene()
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
