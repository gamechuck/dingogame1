extends Control

################################################################################
## PRIVATE VARS
var _town_id

onready var _name_label := $VBoxContainer/TitleContainer/MissionNameLabel
onready var _description_label := $VBoxContainer/ScrollContainer/DescriptionLabel
onready var _place_description_label := $VBoxContainer/PlaceContainer/PlaceDescriptionLabel
onready var _completed_texture := $CompletedTexture
onready var _start_button := $VBoxContainer/BottomContainer/GoButton
onready var _conditions_label := $VBoxContainer/BottomContainer/VBoxContainer/MissionGoalLabel

################################################################################
## GODOT CALLBACKS

func _ready() -> void:
	_start_button.connect("pressed", self, "_on_start_button_pressed")


################################################################################
## PUBLIC FUNCTIONS

func setup(target_id : String):
	_town_id = target_id

	var town_state : classTownState = State.get_town_state_by_id(_town_id)

	if town_state:
		if town_state.completed:
			 _completed_texture.show()
		else:
			_completed_texture.hide()

		_name_label.text = town_state.get_name()
		_place_description_label.text = town_state.get_place_description()
		_description_label.text = town_state.get_description()

		var win_conditions := town_state.get_human_readable_conditions()
		_conditions_label.text = ""
		for condition in win_conditions:
			_conditions_label.text += (condition + "")

	pass

################################################################################
## SIGNAL CALLBACKS

func _on_start_button_pressed():
	State.town_id = _town_id
	Flow.change_scene_to("game")
