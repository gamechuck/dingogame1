extends Node

################################################################################
## ENUMS
enum GAME_STATE { WIN, LOSE }


################################################################################
## CONSTANTS
const SCENE_TOWN_STATE := preload("res://src/autoload/state/TownState.gd")


################################################################################
## SIGNALS
signal game_state_changed # new_state


################################################################################
## PUBLIC VARIABLES
# This can be private function since nobody is calling it from outside
var game_state := -1 setget set_game_state
func set_game_state(v : int) -> void:
	game_state = v
#	_can_update_day_phase = false
	emit_signal("game_state_changed", game_state)

# Called from Town.gd
var loaded_town : classTown setget set_loaded_town
func set_loaded_town(v : classTown) -> void:
	loaded_town = v

#################################################################################
### GODOT CALLBACKS
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


func save_state_to_context() -> Dictionary:
	var context := {}
	return context

################################################################################
## SIGNAL CALLBACKS

func _on_game_won() -> void:
	set_game_state(GAME_STATE.WIN)

func _on_game_lost() -> void:
	set_game_state(GAME_STATE.LOSE)
