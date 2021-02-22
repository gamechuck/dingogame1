extends Control

onready var _play_next_lvl_button  := $VB/PC/HB/MC/VB/PlayNextLevelButton
onready var _restart_button := $VB/PC/HB/MC/VB/RestartButton
onready var _back_button := $VB/PC/HB/MC/VB/BackButton
onready var _state_label := $VB/PC/HB/StateLabel

var game_state := 0 setget set_game_state
func set_game_state(v : int) -> void:
	game_state = v
#
#	if _state_label:
#		match game_state:
#			State.GAME_STATE.WIN:
#				if State.has_next_level():
#					_play_next_lvl_button.show()
#				else:
#					_play_next_lvl_button.hide()
#				_state_label.text = "You win!"
#			State.GAME_STATE.LOSE:
#				_play_next_lvl_button.hide()
#				_state_label.text = "You lose!"

func _ready() -> void:
	set_game_state(game_state)

	if not Engine.editor_hint:
		_play_next_lvl_button.connect("pressed", self, "_on_play_next_lvl_button_pressed")
		_restart_button.connect("pressed", self, "_on_restart_button_pressed")
		_back_button.connect("pressed", self, "_on_back_button_pressed")
		hide()

func _on_play_next_lvl_button_pressed() -> void:
	State.set_next_level()
	Flow.change_scene_to("game")

func _on_restart_button_pressed() -> void:
	Flow.deferred_reload_current_scene(false)
#	hide()

func _on_back_button_pressed() -> void:
	Flow.change_scene_to("menu")
