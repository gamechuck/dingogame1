extends Node
## This script loads and manages all settings and options as saved in default_options.cfg
## and user_settings.cfg (if available).
## Custom setter/getters should be defined whenever required!
#
## if you add new physics layer in project settings, update it here as well
#
#
#signal version_visibility_changed
#signal input_mode_changed
#
## Load the game and editor options and settings from both the default and the user-modified one.
#func load_optionsCFG() -> int:
#	var config : ConfigFile = ConfigFile.new()
#	var file : File = File.new()
#	var error : int = config.load(Flow.DEFAULT_OPTIONS_PATH)
#	if error == OK: # if not, something went wrong with the file loading.
#		error = _parse_config(config)
#		print("Succesfully loaded and processed '{0}'.".format([Flow.DEFAULT_OPTIONS_PATH]))
#		# Check if there are any user-modified options that need to be overwritten.
#		if file.file_exists(Flow.USER_SETTINGS_PATH):
#			if ConfigData.verbose_mode:
#				print("Attempting to load user-modified settings from '{0}'.".format([Flow.USER_SETTINGS_PATH]))
#			error = config.load(Flow.USER_SETTINGS_PATH)
#			if error == OK: # if not, something went wrong with the file loading.
#				error = _parse_config(config)
#				if ConfigData.verbose_mode:
#					print("Succesfully loaded and processed '{0}'.".format([Flow.USER_SETTINGS_PATH]))
#				return OK
#			else:
#				push_error("Failed to load '{0}', check file format!".format([Flow.DEFAULT_OPTIONS_PATH]))
#				return error
#		else:
#			return OK
#	else:
#		push_error("Failed to open '{0}', check file availability!".format([Flow.DEFAULT_OPTIONS_PATH]))
#		return error
#
## Load the default options without checking for any previously saved user_settings
## This basically resets the user_settings since they will be overwritten!
#func reset_optionsCFG() -> int:
#	var config : ConfigFile = ConfigFile.new()
#	var error : int = config.load(Flow.DEFAULT_OPTIONS_PATH)
#	if error == OK: # if not, something went wrong with the file loading.
#		error = _parse_config(config)
#		print("Succesfully re-loaded and processed '{0}'.".format([Flow.DEFAULT_OPTIONS_PATH]))
#		return OK
#	else:
#		push_error("Failed to open '{0}', check file availability!".format([Flow.DEFAULT_OPTIONS_PATH]))
#		return error
#
## Save settings that can be user-modified to a configuration file.
#func save_settingsCFG() -> int:
#	var config : ConfigFile = ConfigFile.new()
#	var error : int = config.load(Flow.DEFAULT_OPTIONS_PATH)
#	if error == OK: # if not, something went wrong with the file loading.
#		for section_id in config.get_sections():
#			# Only save the sections that begin with "settings"!
#			if section_id.begins_with("settings"):
#				for key in config.get_section_keys(section_id):
#					if ConfigData.get(key) != null:
#						config.set_value(section_id, key, ConfigData.get(key))
#					else:
#						push_error("Failed to set configuration property {0}!".format([key]))
#			else: # Erase the section, since it doesnt pertain to any user-modifiable settings!
#				config.erase_section(section_id)
#		return _synchronize_user_settings(config)
#	else:
#		push_error("Failed to open '{0}', check file availability!".format([Flow.DEFAULT_OPTIONS_PATH]))
#		return error
#
## Check if 'user_settings.cfg' already exists and only overwrite settings.
## Thus leaving any custom dev options alone.
#func _synchronize_user_settings(config : ConfigFile) -> int:
#	var old_config : ConfigFile = ConfigFile.new()
#	var error : int = old_config.load(Flow.USER_SETTINGS_PATH)
#	if  error == OK:
#		for section_id in config.get_sections():
#			for key in config.get_section_keys(section_id):
#				old_config.set_value(section_id, key, ConfigData.get(key))
#
#	return old_config.save(Flow.USER_SETTINGS_PATH)
#
## Load all configuration variables to the ConfigData autoload script.
#func _parse_config(config : ConfigFile) -> int:
#	for section_id in config.get_sections():
#		for key in config.get_section_keys(section_id):
#			if ConfigData.get(key) != null:
#				ConfigData.set(key, config.get_value(section_id, key, ConfigData.get(key)))
#			else:
#				push_error("Failed to set configuration property {0}!".format([key]))
#	return OK
#
#################################################################################
### CONFIG ENTRIES
#
## [common]
var verbose_mode := true
#
#
#
#################################################################################
### CONFIG SETTERS
