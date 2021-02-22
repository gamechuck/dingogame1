extends classMenuTab

onready var _back_button := $VBoxContainer/BackButton
onready var _reset_button := $VBoxContainer/ResetButton

onready var _sections_vbox := $VBoxContainer/ScrollContainer/SectionsHBox

func _ready() -> void:
	var _error : int = _back_button.connect("pressed", self, "_on_back_button_pressed")
	_error = _reset_button.connect("pressed", self, "_on_reset_button_pressed")

func update_tab() -> void:
	_back_button.grab_focus()

	update_sections()

func update_sections() -> void:
	for child in _sections_vbox.get_children():
		if child is classSection:
			child.update_section()
		elif child is VBoxContainer:
			for grandchild in child.get_children():
				if grandchild is classSection:
					grandchild.update_section()

func _on_back_button_pressed() -> void:
	# Save the user-settings to the local system.
	var _error := ConfigData.save_settingsCFG()
	if _error != OK:
		push_error("Failed to save settings to local storage! Check console for clues!")

	._on_back_button_pressed()

func _on_reset_button_pressed() -> void:
	# Reset the user-settings to the default ones.
	var _error := ConfigData.reset_optionsCFG()
	if _error != OK:
		push_error("Failed to reset settings to the default ones! Check console for clues!")

	# Update here without calling 'update_tab()' to avoid grabbing focus.
	update_sections()
