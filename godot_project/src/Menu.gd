extends Control

var _quitting := false

func _ready():
	_quitting = false
	$StartButton.connect("pressed", self, "_on_start_button_pressed")
	$QuitButton.connect("pressed", self, "_on_quit_button_pressed")

func _input(event):
	if event is InputEventKey or event is InputEventJoypadButton:
		if event.scancode == 16777217: # ESC key
			_quitting = true
			Flow.deferred_quit()
			return
		if not _quitting:
			Flow.change_scene_to("game")

func _on_start_button_pressed():
	Flow.change_scene_to("game")

func _on_quit_button_pressed():
	Flow.deferred_quit()
