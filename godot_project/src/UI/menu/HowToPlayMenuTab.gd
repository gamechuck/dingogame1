extends classMenuTab

#const SCENE_MISSION_PANEL := preload("res://src/UI/menu/MissionPanel.tscn")

onready var _back_button := $VBoxContainer/BackButton

func _ready():
	var _error : int = _back_button.connect("pressed", self, "_on_back_button_pressed")


func update_tab():
	_back_button.grab_focus()
