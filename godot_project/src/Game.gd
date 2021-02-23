extends Node2D

################################################################################
## CONSTANTS
const SCENE_TOWN := preload("res://src/game/Town.tscn")

################################################################################
## GODOT CALLBACKS
func _ready():
	randomize()
	_spawn_town()


################################################################################
## PRIVATE FUNCTIONS
func _spawn_town() -> void:
	for child in $ViewportContainer.get_children():
		if child is classTown:
			$ViewportContainer.remove_child(child)
			child.queue_free()
#
	var town_scene = SCENE_TOWN.instance()
	$ViewportContainer.add_child(town_scene)

func _on_game_state_changed(game_state : int) -> void:
	match game_state:
		State.GAME_STATE.WIN:
			$UI/GameOverlay.show_end_overlay(State.GAME_STATE.WIN)
		State.GAME_STATE.LOSE:
			$UI/GameOverlay.show_end_overlay(State.GAME_STATE.LOSE)
