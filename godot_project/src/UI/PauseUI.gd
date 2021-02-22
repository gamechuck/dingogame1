extends Control

onready var _pause_tab_container := $PauseTabContainer

func _ready():
	var _error : int = Flow.connect("pause_toggled", self, "_on_pause_toggled")

func _on_pause_toggled():
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		show()
	else:
		hide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed():
			Input.set_custom_mouse_cursor(Flow.CURSOR_PRESSED_TEXTURE, Input.CURSOR_ARROW)
		else:
			Input.set_custom_mouse_cursor(Flow.CURSOR_TEXTURE, Input.CURSOR_ARROW)

func show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_pause_tab_container.set_current_tab(classPauseTab.TABS.MAIN)
	visible = true
	# Enable the input!
	set_process_input(true)

	Input.set_custom_mouse_cursor(Flow.CURSOR_TEXTURE, Input.CURSOR_ARROW)

func hide():
	# Save the user-settings to the local system.
	# Under the condition that the current tab was the settings one.
	if _pause_tab_container.get_current_tab() == classPauseTab.TABS.SETTINGS:
		var _error := ConfigData.save_settingsCFG()
		if _error != OK:
			push_error("Failed to save settings to local storage! Check console for clues!")
	visible = false
	set_process_input(false)

	if ConfigData.is_using_keyboard_input():
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
