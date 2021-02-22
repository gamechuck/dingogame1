tool
extends VBoxContainer

export(bool) var has_visible_description : bool = true setget set_has_visible_description
func set_has_visible_description(value : bool) -> void:
	has_visible_description = value
	$HBoxContainer.visible = value

var control_dict := {
	Global.CONTROL_SCHEME.MOUSE: {
		"text": "Mouse",
		"attack": "Left Mouse Button",
		"movement": "Right Mouse Button",
	},
	Global.CONTROL_SCHEME.KEYBOARD: {
		"text": "Keyboard",
		"attack": "E",
		"movement": "WASD\nArrow Keys",
	},
	Global.CONTROL_SCHEME.HYBRID: {
		"text": "Keyboard + mouse",
		"attack": "E + LMB",
		"movement": "WASD\nArrow Keys + Mouse",
	}
}

export(Global.CONTROL_SCHEME) var control_scheme : int = Global.CONTROL_SCHEME.MOUSE setget set_control_scheme
func set_control_scheme(value : int):
	control_scheme = value
	update_control_labels()

func _on_item_selected(index : int) -> void:
	self.control_scheme = $VBoxContainer/OptionButton.get_item_id(index)
	ConfigData.set_input_mode(control_scheme)
	ConfigData.save_settingsCFG()

func _ready():
	var _error := $VBoxContainer/OptionButton.connect("item_selected", self, "_on_item_selected")

	if not Engine.editor_hint:
		for key in control_dict.keys():
			$VBoxContainer/OptionButton.add_item(control_dict[key].text, key)

		update_setting()

func update_setting() -> void:
	$VBoxContainer/OptionButton.selected = $VBoxContainer/OptionButton.get_item_index(ConfigData.input_mode)
	update_control_labels()

func update_control_labels() -> void:
	var controls : Dictionary = control_dict[control_scheme]
	if is_inside_tree():
		for key in controls.keys():
			match key:
				"attack":
					$HBoxContainer/AttackVBox/ControlLabel.text = controls[key]
				"movement":
					$HBoxContainer/MovementVBox/ControlLabel.text = controls[key]
