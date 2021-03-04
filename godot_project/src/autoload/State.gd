extends Node


################################################################################
## SIGNALS
signal state_changed


################################################################################
## PUBLIC VARIABLES
var current_highscores := []


################################################################################
## PUBLIC FUNCTIONS
func set_highscore(score : int, player_name : String) -> void:
	if player_name == "":
		return
	current_highscores.append({"name": player_name, "score": score})
	current_highscores.sort_custom(self, "_sort_highscore")
	emit_signal("state_changed")

func get_highscores() -> Array:
	return current_highscores

func is_highscore_set(score : int) -> bool:
	if not current_highscores or current_highscores.empty() or current_highscores.size() < 10:
		return true
	for i in current_highscores:
		if current_highscores[i].get("score") < score:
			return true
	return false


func _sort_highscore(value_a : Dictionary, value_b : Dictionary) -> bool:
	if value_a.get("score") > value_b.get("score"):
		return true
	return false
