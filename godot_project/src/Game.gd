extends Node2D


################################################################################
## CONSTANTS
const SCENE_TOWN := preload("res://src/game/Town.tscn")


################################################################################
## PRIVATE VARIABLES
onready var _game_timer := $Timer

var _town : classTown

################################################################################
## GODOT CALLBACKS
func _ready():
	randomize()
	_spawn_town()
	_game_timer.connect("timeout", self, "_on_game_timer_timeout")


################################################################################
## PRIVATE FUNCTIONS
func _spawn_town() -> void:
	for child in $ViewportContainer.get_children():
		if child is classTown:
			$ViewportContainer.remove_child(child)
			child.queue_free()
#
	_town = SCENE_TOWN.instance()
	$ViewportContainer.add_child(_town)

func _finish_game() -> void:
	# disable player movememnt
	_town.get_player().disable()
	# calculate score
	var thief_score = _town.get_thief_score()
	var trafo_score = _town.get_trafo_score()
	print("Score: " + str(thief_score + trafo_score))
	# display score
	# enable end game UI
	# enable level restart
	pass

################################################################################
## GODOT CALLBACKS
func _on_game_timer_timeout() -> void:
	_finish_game()
