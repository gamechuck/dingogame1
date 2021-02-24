extends Control

onready var _start_button := $Button

func _ready():
	_start_button.connect("pressed", self, "_on_start_button_pressed")

func _on_start_button_pressed():
	Flow.change_scene_to("game")
