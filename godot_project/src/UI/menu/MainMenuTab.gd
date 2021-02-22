extends classMenuTab

#onready var _quick_start_button := $PanelContainer/VBoxContainer/VBoxContainer/QuickstartButton

onready var _start_button := $PanelContainer/VBoxContainer/VBoxContainer/StartButton
#onready var _how_to_play_button := $PanelContainer/VBoxContainer/VBoxContainer/HowToPlayButton
#onready var _settings_button := $PanelContainer/VBoxContainer/VBoxContainer/SettingsButton
onready var _quit_button := $PanelContainer/VBoxContainer/VBoxContainer/QuitButton

func _ready():
	var _error : int = _start_button.connect("pressed", self, "_on_start_button_pressed")
#	_error = _how_to_play_button.connect("pressed", self, "_on_how_to_play_button_pressed")
#	_error = _settings_button.connect("pressed", self, "_on_settings_button_pressed")

	# Hide quick start button in case this is game build.
#	if OS.has_feature("standalone"):
#		_quick_start_button.hide()
#	else:
#		_quick_start_button.connect("pressed", self, "_on_quick_start_button_pressed")
#		_quick_start_button.show()

	# Hide the quit button if the OS is HTML!
	# Since this button won't work anyway...
	if OS.get_name() == "HTML5":
		_quit_button.visible = false
	else:
		_quit_button.visible = true
		_error = _quit_button.connect("pressed", self, "_on_quit_button_pressed")

func update_tab():
	_start_button.grab_focus()

	# Update the control scheme button here!
#	$PanelContainer/VBoxContainer/VBoxContainer/ControlSchemeHBox.update_setting()

func _on_quick_start_button_pressed():
	Flow.change_scene_to("game")
#	State.set_quick_start_level()

func _on_start_button_pressed():
	Flow.change_scene_to("game")
#	emit_signal("button_pressed", TABS.WORLD_MAP)

#func _on_how_to_play_button_pressed():
#	emit_signal("button_pressed", TABS.HOW_TO_PLAY)

#func _on_settings_button_pressed():
#	emit_signal("button_pressed", TABS.SETTINGS)
