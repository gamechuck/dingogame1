extends classMenuTab

#const MISSION_PLACE_PANEL_SCENE := preload("res://src/UI/menu/map/MissionPlacePanel.tscn")

################################################################################
## PRIVATE VARS

var _mission_place_panels : = []

onready var _mission_scroll_panel := $MissionScrollPanel
onready var _mission_places_parent := $MissionPlaces
onready var _back_button := $BackButton

################################################################################
## GODOT CALLBACKS

func _ready() -> void:
	_setup_mission_places()
	_connect_signals()


################################################################################
## PRIVATE FUNCTIONS

func _setup_mission_places() -> void:
	_mission_place_panels = _mission_places_parent.get_children()
	var index = 0
	for state in State.town_states:
		_mission_place_panels[index].setup(State.town_states.get(state))
		index += 1

func _connect_signals() -> void:
	_back_button.connect("pressed", self, "_on_back_button_pressed")
	for mission_place in _mission_place_panels:
		mission_place.connect("button_pressed", self, "_on_mission_place_pressed")


################################################################################
## SIGNAL CALLBACKS

func _on_mission_place_pressed(town_id : String) -> void:
	_mission_scroll_panel.setup(town_id)
	_mission_scroll_panel.show()


func _on_back_button_pressed() -> void:
	._on_back_button_pressed()
	_mission_scroll_panel.hide()


