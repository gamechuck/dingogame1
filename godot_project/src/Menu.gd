extends Control

onready var _highscore_value_label := $HighscorePanel/HBoxContainer/Value


func _ready():
	$StartButton.connect("pressed", self, "_on_start_button_pressed")
	$QuitButton.connect("pressed", self, "_on_quit_button_pressed")
	#_highscore_value_label.text = str(State.get_highscore())
	State.connect("state_changed", self, "_on_state_changed")

func _on_start_button_pressed():
	Flow.change_scene_to("game")

func _on_quit_button_pressed():
	Flow.deferred_quit()

func _on_state_changed() -> void:
	_highscore_value_label.text = str(State.get_highscore())
