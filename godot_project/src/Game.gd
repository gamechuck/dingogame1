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
onready var _end_game_panel := $UI/EndGamePanel
onready var _background := $UI/Background
onready var _viewport := $ViewportContainer

onready var _score_value := $UI/EndGamePanel/EndGameMessage/ScoreValue
onready var _buttons := $UI/Buttons
onready var _button_restart := $UI/Buttons/ButtonRestart
onready var _button_main_menu := $UI/Buttons/ButtonMainMenu

onready var _highscore_list := $UI/EndGamePanel/HighscorePanel/HighscoreList
onready var _highscore_labels := _highscore_list.get_children()

onready var _highscore_input_UI := $UI/EndGamePanel/HighscoreInput
onready var _name_input_label := $UI/EndGamePanel/HighscoreInput/NameInputLabel
#onready var _button_submit := $UI/EndGamePanel/HighscoreInput/ButtonSubmit

var _town : classTown
var _last_highscore = 0
var _game_finished = false

################################################################################
## GODOT CALLBACKS
func _ready():
	randomize()
	_spawn_town()
	_game_timer.wait_time = Flow.game_data.get("duration", 60.0)
	_game_timer.start()
	_end_game_panel.hide()
	_background.hide()
	_game_timer.connect("timeout", self, "_on_game_timer_timeout")
	#_button_submit.connect("pressed", self, "_on_highscore_input_submit_button_pressed")
	_button_restart.connect("pressed", self, "_on_restart_button_pressed")
	_button_main_menu.connect("pressed", self, "_on_main_menu_button_pressed")
	KeyboardBackend.connect("input_buffer_changed", self, "_on_keyboard_input_buffer_changed")
	_highscore_labels.remove(0) # Just remove first child since that is title label
	_game_finished = false

func _input(event):
	if _game_finished:
		if event is InputEventJoypadButton or event is InputEventKey:
			Flow.change_scene_to("menu")


################################################################################
## PRIVATE FUNCTIONS
func _spawn_town() -> void:
	_town = SCENE_TOWN.instance()
	_viewport.add_child(_town)
	connect("game_finish", _town, "_on_game_finished")

func _finish_game() -> void:
	emit_signal("game_finish")
	_game_finished = true
	# Calculate score
	var score = _town.get_thief_score() + _town.get_trafo_score()
	# Display score
	_score_value.text = str(score) + " GwH OF ELECTRICITY"
	if State.is_highscore_set(score) and score > 0:
		_last_highscore = score
		# Enable UI for name input
		_highscore_input_UI.show()
		_highscore_list.hide()
		_buttons.hide()

		KeyboardBackend.clear_input_buffer_on_hide = false
		KeyboardBackend.set_visible(true)
	else:
		KeyboardBackend.clear_input_buffer_on_hide = true
		KeyboardBackend.set_visible(false)
		_update_highscore_list()
		_highscore_input_UI.hide()
		_highscore_list.show()
		_buttons.show()

	_background.show()
	_end_game_panel.show()
	_viewport.hide()

func _update_highscore_list() -> void:
	for highscore_label in _highscore_labels:
		highscore_label.text = ""
		highscore_label.hide()

	var highscores : Array = State.get_highscores()
	for i in _highscore_labels.size():
		if i >= highscores.size():
			break
		var highscore_value = "     " + str(highscores[i].get("name"))
		highscore_value += "  :  " +  str(highscores[i].get("score")) + "       "
		_highscore_labels[i].text = highscore_value
		_highscore_labels[i].show()


################################################################################
## GODOT CALLBACKS
func _on_game_timer_timeout() -> void:
	_finish_game()

func _on_restart_button_pressed() -> void:
	Flow.deferred_reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	Flow.change_scene_to("menu")

func _on_highscore_input_submit_button_pressed() -> void:
	State.set_highscore(_last_highscore, KeyboardBackend.input_buffer)
	KeyboardBackend.input_buffer = ""
	_update_highscore_list()
	_highscore_list.show()
	_highscore_input_UI.hide()
	_buttons.show()

func _on_keyboard_input_buffer_changed(value : String) -> void:
	_name_input_label.text = value
