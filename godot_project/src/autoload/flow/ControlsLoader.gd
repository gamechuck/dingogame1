# Loader/saver for all the game & editor controls.
extends Node

func load_controlsJSON() -> int:
	## Load all the controls from the default JSON.
	var file : File = File.new()
	var error : int = OK
	var default_controls : Dictionary = Flow.load_JSON(Flow.DEFAULT_CONTROLS_PATH)
	var default_version : int = default_controls.get("version", -1)
	# First check if there are user-specific controls available that can be loaded...
	if file.file_exists(Flow.USER_CONTROLS_PATH):
		if ConfigData.verbose_mode: print("Attempting to load user-modified controls from '{0}'.".format([Flow.USER_CONTROLS_PATH]))
		var controls_dictionary : Dictionary = Flow.load_JSON(Flow.USER_CONTROLS_PATH)
		var user_version : int = controls_dictionary.get("version", -1)
		if controls_dictionary.empty():
			push_error("Failed to process the user-modified controls, falling back to default controls.")
			controls_dictionary = default_controls
		# Check if the saved 'user_controls.json' is still valid!
		elif user_version < default_version:
			push_warning("Version of user-modified controls (= {0}) is lower than default version (= {1}), falling back to default controls.".format([user_version, default_version]))
			controls_dictionary = default_controls
		error += _create_controls(controls_dictionary)
	else:
		if ConfigData.verbose_mode: print("No user-modified are defined, loading default controls from '{0}' instead.".format([Flow.DEFAULT_CONTROLS_PATH]))
		error += _create_controls(default_controls)
	return error

func save_controlsJSON() -> int:
	## Save new user-modified controls to the user://-folder
	var default_controls : Dictionary = Flow.load_JSON(Flow.DEFAULT_CONTROLS_PATH)
	var user_controls := default_controls.duplicate(true)

	for key in user_controls.keys():
		if key == "version":
			continue
		for control in user_controls[key]:
			if control.has("action"):
				var action_list := InputMap.get_action_list(control.action)
				var events : Array = control.get("events", [])
				events.clear()
				for event in action_list:
					var parsed_dict := {}
					if event is InputEventKey:
						parsed_dict.scancode = OS.get_scancode_string(event.scancode)
						if event.alt: parsed_dict.alt = event.alt
						if event.control: parsed_dict.control = event.control
					elif event is InputEventMouseButton:
						parsed_dict.button_index = event.button_index
					elif event is InputEventJoypadMotion:
						parsed_dict.axis = Input.get_joy_axis_string(event.axis)
						parsed_dict.axis_value = event.axis_value
					else:
						continue
					events.append(parsed_dict)

	return Flow.save_JSON(Flow.USER_CONTROLS_PATH, user_controls)

func _create_controls(controls_dictionary : Dictionary) -> int:
	## Create all relevant controls using the controls dictionary.
	# First, remove all current actions from the InputMap
	# DO NOT DO THIS! THIS MESSES WITH CONTROL DEFAULTS!
	#var actions : Array = InputMap.get_actions()
	#for action in actions:
	#	InputMap.erase_action(action)

	for key in controls_dictionary.keys():
		if key == "version":
			continue
		for control in controls_dictionary[key]:
			if control.has("action"):
				if InputMap.has_action(control.action):
					# Erase the action if it already exists!
					InputMap.erase_action(control.action)
				InputMap.add_action(control.action)
				if ConfigData.verbose_mode:
					print("	> Added action '{0}' to InputMap.".format([control.action]))
				if control.has("events"):
					for event in control.events:
						if event.has("scancode"):
							_create_inputEventKey(control.action, event)
						elif event.has("button_index"):
							if event.get("is_joypad", false):
								_create_inputEventJoypadButton(control.action, event)
							else:
								_create_inputEventMouseButton(control.action, event)
						elif event.has("axis"):
							_create_inputEventJoypadMotion(control.action, event)
	return OK

func _create_inputEventKey(action : String, event : Dictionary) -> void:
	## Add a keyboard event to an action.
	var event_key : InputEventKey = InputEventKey.new()
	event_key.scancode = OS.find_scancode_from_string(event.scancode)
	event_key.alt = event.get("alt", false)
	event_key.control = event.get("control", false)
	InputMap.action_add_event(action, event_key)
	if ConfigData.verbose_mode:
		print("		> Added event with keyboard with scancode '{0}' ('{1}').".format([
			event_key.scancode,
			OS.get_scancode_string(event_key.scancode)
		]))

func _create_inputEventMouseButton(action : String, event : Dictionary) -> void:
	## Add a mouse button event to an action.
	var event_button : InputEventMouseButton = InputEventMouseButton.new()
	event_button.button_index = event.button_index
	event_button.device = -1
	InputMap.action_add_event(action, event_button)
	if ConfigData.verbose_mode:
		print("		> Added event for mouse with button_index '{0}'.".format([
			event_button.button_index
		]))

func _create_inputEventJoypadMotion(action : String, event : Dictionary) -> void:
	## Add a joypad motion event to an action.
	var event_joypad_motion : InputEventJoypadMotion = InputEventJoypadMotion.new()
	event_joypad_motion.axis = Input.get_joy_axis_index_from_string(event.axis)
	event_joypad_motion.axis_value = event.get("axis_value", 1)
	InputMap.action_add_event(action, event_joypad_motion)
	if ConfigData.verbose_mode:
		print("		> Added event for joypad with axis '{0}' ('{1}') and value '{2}'.".format([
			event_joypad_motion.axis,
			Input.get_joy_axis_string(event_joypad_motion.axis),
			event_joypad_motion.axis_value
		]))

func _create_inputEventJoypadButton(action : String, event : Dictionary) -> void:
	## Add a joypad motion event to an action.
	var event_joypad_button : InputEventJoypadButton = InputEventJoypadButton.new()
	event_joypad_button.button_index = event.button_index
	event_joypad_button.device = -1
	InputMap.action_add_event(action, event_joypad_button)
	if ConfigData.verbose_mode:
		print("		> Added event for joypad with button_index '{0}'.".format([
			event_joypad_button.button_index
		]))
