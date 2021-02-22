extends Node2D

export var _display_time := 2.0

onready var _timer : Timer = $Timer

func _ready() -> void:
	_timer.set_wait_time(_display_time)
	_timer.connect("timeout", self, "_on_timeout_disable")
	_timer.start()

func _on_timeout_disable() -> void:
	hide()
