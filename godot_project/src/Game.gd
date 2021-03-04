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
onready var _ui_root := $UI/VBoxContainer

onready var _highscore_input_UI := $UI/VBoxContainer/HighscoreInput
onready var _name_input_label := $UI/VBoxContainer/HighscoreInput/NameInputLabel
onready var _button_submit := $UI/VBoxContainer/HighscoreInput/ButtonSubmit

onready var _score_value := $UI/VBoxContainer/Highscore/ScoreValue
onready var _buttons := $UI/VBoxContainer/Buttons
onready var _button_restart := $UI/VBoxContainer/Buttons/ButtonRestart
onready var _button_main_menu := $UI/VBoxContainer/Buttons/ButtonMainMenu

onready var _viewport := $ViewportContainer

var _town : classTown
var _last_highscore = 0

################################################################################
## GODOT CALLBACKS
func _ready():
	randomize()
	_spawn_town()
	_game_timer.wait_time = Flow.game_data.get("duration", 60.0)
	_game_timer.start()
	_ui_root.hide()
	_game_timer.connect("timeout", self, "_on_game_timer_timeout")
	_button_submit.connect("pressed", self, "_on_highscore_input_submit_button_pressed")
	_button_restart.connect("pressed", self, "_on_restart_button_pressed")
	_button_main_menu.connect("pressed", self, "_on_main_menu_button_pressed")
	KeyboardBackend.connect("input_buffer_changed", self, "_on_keyboard_input_buffer_changed")


################################################################################
## PRIVATE FUNCTIONS
func _spawn_town() -> void:
	_town = SCENE_TOWN.instance()
	_viewport.add_child(_town)
	connect("game_finish", _town, "_on_game_finished")

func _finish_game() -> void:
	emit_signal("game_finish")

	# Calculate score
	var score = _town.get_thief_score() + _town.get_trafo_score()
	# Display score
	_score_value.text = str(score) + " GwH OF ELECTRICITY"
	if State.is_highscore_set(score) and score > 0:
		_last_highscore = score
		# Enable UI for name input
		_highscore_input_UI.show()
		KeyboardBackend.clear_input_buffer_on_hide = false
		KeyboardBackend.set_visible(true)
		_buttons.hide()
	else:
		KeyboardBackend.clear_input_buffer_on_hide = true
		KeyboardBackend.set_visible(false)
		_highscore_input_UI.hide()
		_buttons.show()

	# Display end game UI
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

func _on_highscore_input_submit_button_pressed() -> void:
	State.set_highscore(_last_highscore, KeyboardBackend.input_buffer)
	KeyboardBackend.input_buffer = ""
	_highscore_input_UI.hide()
	_buttons.show()

func _on_keyboard_input_buffer_changed(value : String) -> void:
	_name_input_label.text = value
