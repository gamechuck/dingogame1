extends Node2D


################################################################################
## SIGNALS
signal game_finish


################################################################################
## CONSTANTS
const SCENE_TOWN := preload("res://src/game/Town.tscn")


################################################################################
## PRIVATE VARIABLES
onready var _game_timer := $Timer
# UI STUFF
onready var _ui_root := $UI
onready var _score_value := $UI/VBoxContainer/ScoreValue
onready var _highscore_value := $UI/VBoxContainer/HighscoreValue
onready var _button_restart := $UI/VBoxContainer/HBoxContainer/ButtonRestart
onready var _button_main_menu := $UI/VBoxContainer/HBoxContainer/ButtonMainMenu

onready var _viewport := $ViewportContainer

var _town : classTown


################################################################################
## GODOT CALLBACKS
func _ready():
	randomize()
	_spawn_town()
	_ui_root.hide()
	_game_timer.connect("timeout", self, "_on_game_timer_timeout")
	_button_restart.connect("pressed", self, "_on_restart_button_pressed")
	_button_main_menu.connect("pressed", self, "_on_main_menu_button_pressed")


################################################################################
## PRIVATE FUNCTIONS
func _spawn_town() -> void:
	_town = SCENE_TOWN.instance()
	_viewport.add_child(_town)
	connect("game_finish", _town, "_on_game_finished")

func _finish_game() -> void:
	emit_signal("game_finish")

	# calculate score
	var score = _town.get_thief_score() + _town.get_trafo_score()
	if score > State.get_highscore():
		State.set_highscore(score)

	_highscore_value.text = str(State.get_highscore())
	# display score
	_score_value.text = str(score)
	# enable end game UI

	_ui_root.show()
	_viewport.hide()

################################################################################
## GODOT CALLBACKS
func _on_game_timer_timeout() -> void:
	_finish_game()

func _on_restart_button_pressed() -> void:
	Flow.deferred_reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	Flow.change_scene_to("menu")
