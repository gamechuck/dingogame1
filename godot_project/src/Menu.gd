extends Control

onready var _background := $Background

var _quitting := false
var _pressed_once := false
var _pressed_twice := false

func _ready():
	_quitting = false
	_pressed_once = false
	#AudioEngine.play_music("background_music")

func _input(event):
	if event is InputEventKey or event is InputEventJoypadButton:
		if _pressed_once:
			if event is InputEventKey and event.scancode == 16777217: # ESC key
				_quitting = true
				Flow.deferred_quit()
				return
			if not _quitting:
				if not _pressed_twice:
					_background.hide()
					_pressed_twice = true
				else:
					Flow.change_scene_to("game")

		_pressed_once = true

