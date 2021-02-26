extends Node


################################################################################
## SIGNALS
signal state_changed

################################################################################
## PUBLIC VARIABLES
var current_highscore := 0 setget set_highscore, get_highscore
func set_highscore(value : int) -> void:
	current_highscore = value
	emit_signal("state_changed")

func get_highscore() -> int:
	return current_highscore
