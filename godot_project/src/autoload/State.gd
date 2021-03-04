extends Node


################################################################################
## SIGNALS
signal state_changed

################################################################################
## PUBLIC VARIABLES
var current_highscore := {}

func set_highscore(score : int, player_name : String) -> void:
	if player_name == "":
		return
	current_highscore[player_name] = score
	emit_signal("state_changed")

func is_highscore_set(score : int) -> bool:
	if not current_highscore or current_highscore.empty():
		return true
	for highscore in current_highscore:
		if current_highscore[highscore] < score:
			return true
	return false
