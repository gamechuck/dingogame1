extends Node

################################################################################
## ENUMS
enum GAME_STATE { WIN, LOSE }


################################################################################
## SIGNALS
signal game_state_changed # new_state


################################################################################
## PUBLIC VARIABLES
# This can be private function since nobody is calling it from outside
var game_state := -1 setget set_game_state
func set_game_state(v : int) -> void:
	game_state = v
	emit_signal("game_state_changed", game_state)

# Called from Town.gd
var loaded_town : classTown setget set_loaded_town
func set_loaded_town(v : classTown) -> void:
	loaded_town = v


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
