extends Node

var enabled := true

var enabled_categories := [
#	"CASE",
#	"SPAWNING",
#	"BRAIN_BUILDING",
#	"STATE",
]

func log(category : String, message : String) -> void:
	if not enabled:
		return
	if not category in enabled_categories:
		return
	print("[", category, "] ", message)
