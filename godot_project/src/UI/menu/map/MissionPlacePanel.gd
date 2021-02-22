class_name classMissionPlace
extends Control

signal button_pressed

var _town_id := ""

onready var _place_name_label := $MissionPlace/PlaceNameLabel

func _ready() -> void:
	connect("pressed", self, "_on_button_pressed")

func setup(town_state : classTownState) -> void:
	_town_id = town_state.id
	_place_name_label.text = town_state.name

	if town_state.debug_level:
		hide()


func _on_button_pressed() -> void:
	emit_signal("button_pressed", _town_id)


