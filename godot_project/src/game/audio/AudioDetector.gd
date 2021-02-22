extends Node2D

signal audio_source_detected

func _ready() -> void:
	add_to_group("audio_detector")

func on_audio_source_detected(source_owner : Node2D, spawn_position : Vector2, source_data : Dictionary) -> void:
	emit_signal("audio_source_detected", source_owner, spawn_position, source_data)

