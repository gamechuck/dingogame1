extends Node


################################################################################
## SIGNALS
signal state_changed


################################################################################
## PUBLIC VARIABLES
var current_highscores := []


################################################################################
## GODOT CALLBACKS
func _ready():
	_load_stateJSON()


################################################################################
## PUBLIC FUNCTIONS
func set_highscore(score : int, player_name : String) -> void:
	if player_name == "":
		return
	current_highscores.append({"name": player_name, "score": score})
	current_highscores.sort_custom(self, "_sort_highscore")
	var size = current_highscores.size()
	if size > 10:
		for i in range(size, 10, -1):
			current_highscores.erase(i)

	_save_stateJSON()
	emit_signal("state_changed")

func get_highscores() -> Array:
	return current_highscores

func is_highscore_set(score : int) -> bool:
	if not current_highscores or current_highscores.empty() or current_highscores.size() < 10:
		return true
	for i in current_highscores.size():
		if current_highscores[i].get("score") < score:
			return true
	return false


################################################################################
## PRIVATE FUNCTIONS
func _load_stateJSON(path : String = Flow.USER_SAVE_PATH) -> void:
	var context : Dictionary = Flow.load_JSON(path)
	if context.empty():
		pass
	current_highscores = context.get("highscores", [])

func _save_stateJSON(path : String = Flow.USER_SAVE_PATH) -> void:
	# Save the current State to the user://saves-folder.
	var context := {}
	context["highscores"] = current_highscores
	Flow.save_JSON(path, context)

func _sort_highscore(value_a : Dictionary, value_b : Dictionary) -> bool:
	if value_a.get("score") > value_b.get("score"):
		return true
	return false
