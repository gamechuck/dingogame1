tool
extends CheckBox

var toggle_dict := {
	TOGGLE.FULLSCREEN: {
		"text": "Fullscreen"
	}
}

enum TOGGLE {FULLSCREEN = 0}
export(TOGGLE) var toggle_type := TOGGLE.FULLSCREEN setget set_toggle_type
func set_toggle_type(value : int):
	toggle_type = value
	var toggle_settings : Dictionary = toggle_dict[value]
	text = toggle_settings.text

func _on_check_box_toggled(value : bool):
	match toggle_type:
		TOGGLE.FULLSCREEN:
			ConfigData.fullscreen = value

func _ready():
	if not Engine.editor_hint:
		var _error : int = connect("toggled", self, "_on_check_box_toggled")

func update_setting() -> void:
	match toggle_type:
		TOGGLE.FULLSCREEN:
			pressed = ConfigData.fullscreen
