# This script loads and manages all settings and options as saved in default_options.cfg
# and user_settings.cfg (if available).
# Custom setter/getters should be defined whenever required!
extends Node

# if you add new physics layer in project settings, update it here as well
enum PHYSICS_LAYER {
	DEFAULT, CHARACTER, PLAYER, SOLID, CONTAINER, ENEMY, INTERACTABLE, NPC,
	CASE, CORPSE, GROUND, SOUND, NAV_SOLID, SIGHT_OCCLUSION }

signal version_visibility_changed
signal input_mode_changed

# Load the game and editor options and settings from both the default and the user-modified one.
func load_optionsCFG() -> int:
	var config : ConfigFile = ConfigFile.new()
	var file : File = File.new()
	var error : int = config.load(Flow.DEFAULT_OPTIONS_PATH)
	if error == OK: # if not, something went wrong with the file loading.
		error = _parse_config(config)
		print("Succesfully loaded and processed '{0}'.".format([Flow.DEFAULT_OPTIONS_PATH]))
		# Check if there are any user-modified options that need to be overwritten.
		if file.file_exists(Flow.USER_SETTINGS_PATH):
			if ConfigData.verbose_mode:
				print("Attempting to load user-modified settings from '{0}'.".format([Flow.USER_SETTINGS_PATH]))
			error = config.load(Flow.USER_SETTINGS_PATH)
			if error == OK: # if not, something went wrong with the file loading.
				error = _parse_config(config)
				if ConfigData.verbose_mode:
					print("Succesfully loaded and processed '{0}'.".format([Flow.USER_SETTINGS_PATH]))
				return OK
			else:
				push_error("Failed to load '{0}', check file format!".format([Flow.DEFAULT_OPTIONS_PATH]))
				return error
		else:
			return OK
	else:
		push_error("Failed to open '{0}', check file availability!".format([Flow.DEFAULT_OPTIONS_PATH]))
		return error

# Load the default options without checking for any previously saved user_settings
# This basically resets the user_settings since they will be overwritten!
func reset_optionsCFG() -> int:
	var config : ConfigFile = ConfigFile.new()
	var error : int = config.load(Flow.DEFAULT_OPTIONS_PATH)
	if error == OK: # if not, something went wrong with the file loading.
		error = _parse_config(config)
		print("Succesfully re-loaded and processed '{0}'.".format([Flow.DEFAULT_OPTIONS_PATH]))
		return OK
	else:
		push_error("Failed to open '{0}', check file availability!".format([Flow.DEFAULT_OPTIONS_PATH]))
		return error

# Save settings that can be user-modified to a configuration file.
func save_settingsCFG() -> int:
	var config : ConfigFile = ConfigFile.new()
	var error : int = config.load(Flow.DEFAULT_OPTIONS_PATH)
	if error == OK: # if not, something went wrong with the file loading.
		for section_id in config.get_sections():
			# Only save the sections that begin with "settings"!
			if section_id.begins_with("settings"):
				for key in config.get_section_keys(section_id):
					if ConfigData.get(key) != null:
						config.set_value(section_id, key, ConfigData.get(key))
					else:
						push_error("Failed to set configuration property {0}!".format([key]))
			else: # Erase the section, since it doesnt pertain to any user-modifiable settings!
				config.erase_section(section_id)
		return _synchronize_user_settings(config)
	else:
		push_error("Failed to open '{0}', check file availability!".format([Flow.DEFAULT_OPTIONS_PATH]))
		return error

# Check if 'user_settings.cfg' already exists and only overwrite settings.
# Thus leaving any custom dev options alone.
func _synchronize_user_settings(config : ConfigFile) -> int:
	var old_config : ConfigFile = ConfigFile.new()
	var error : int = old_config.load(Flow.USER_SETTINGS_PATH)
	if  error == OK:
		for section_id in config.get_sections():
			for key in config.get_section_keys(section_id):
				old_config.set_value(section_id, key, ConfigData.get(key))

	return old_config.save(Flow.USER_SETTINGS_PATH)

# Load all configuration variables to the ConfigData autoload script.
func _parse_config(config : ConfigFile) -> int:
	for section_id in config.get_sections():
		for key in config.get_section_keys(section_id):
			if ConfigData.get(key) != null:
				ConfigData.set(key, config.get_value(section_id, key, ConfigData.get(key)))
			else:
				push_error("Failed to set configuration property {0}!".format([key]))
	return OK

################################################################################
## CONFIG ENTRIES

# [version]
var version_string := "prototype"
var major_version := 0
var minor_version := 0

# [settings.input]
var input_mode : int = 0 # Global.CONTROL_SCHEME

# [settings.audio]
var master_volume := 100.0 setget set_master_volume
var mute_master := false setget set_mute_master

var music_volume := 100.0 setget set_music_volume
var mute_music := false setget set_mute_music

var sfx_volume := 100.0 setget set_sfx_volume
var mute_sfx := false setget set_mute_sfx

var ambient_sound_volume := 100.0 setget set_ambient_sound_volume
var mute_ambient_sound := false setget set_mute_ambient_sound

# [settings.graphics]
var show_version := true setget set_show_version
var fullscreen := false setget set_fullscreen
var camera_shake_enabled := false

# [common]
var verbose_mode := true
var skip_menu := true

# [game]
var DAY_PHASE_SOUND_ADVANCE_PERCENTAGE = 0.1

# hp
var PLAYER_HP_MAX := 3
var VILLAGER_HP_MAX := 9
var MAYOR_HP_MAX := 2
# attack power
var PLAYER_ATTACK_POWER := 5
var VILLAGER_ATTACK_POWER := 1
var PLAYER_STEALTH_ATTACK_POWER_MODIFIER := 2.0
# speeds
var PLAYER_WALK_SPEED := 70.0
var PLAYER_RUN_SPEED := 120.0
var PLAYER_HUMAN_WALK_SPEED := 50.0
var PLAYER_HUMAN_RUN_SPEED := 100.0
var PLAYER_WHEAT_MOVE_SPEED := 25.0
var PLAYER_CARRY_CORPSE_SPEED := 25.0
var PLAYER_GODMODE_SPEED := 300.0
var NPC_WALK_SPEED := 120.0
var NPC_WHEAT_MOVE_SPEED := 25.0
var NPC_RUN_SPEED := 200.0
var MAYOR_WALK_SPEED := 120.0
var MAYOR_RUN_SPEED := 200.0
# player tracks
var PLAYER_TRACKS_ON_KILL := 40.0
var PLAYER_TRACKS_CAP := 400
var PLAYER_TRACKS_SPAWN_DELAY := 300.0
var PLAYER_TRACKS_DURATION := 8.0
# player knockback
var PLAYER_START_KNOCKBACK_SPEED := 75.0
var PLAYER_KNOCKBACK_DECREASE_RATE := 5.0
# player dash
var PLAYER_ATTACK_DASH_DISTANCE := 20.0
var PLAYER_ATTACK_DASH_SPEED := 200.0
# footsteps
var FOOTSTEPS_SOUND_UPDATE_RATIO := 20000.0

# visibility
var PLAYER_VISIBILITY_FACTOR_INITIAL = 0.4
var PLAYER_VISIBILITY_FACTOR_MOD_MOVING = 0.2
var PLAYER_VISIBILITY_FACTOR_MOD_RUNNING = 0.3
var PLAYER_VISIBILITY_FACTOR_MOD_IN_WHEAT = -0.3

# alertness
var NPC_ALERTNESS_BASE_FACTOR := 20.0

# [game.debug]
var DEBUG_ENABLED := false
# ; player
var DEBUG_PLAYER_GODMODE := false
var DEBUG_PLAYER_NOCLIP := false
var DEBUG_PLAYER_GODSPEED := false
var DEBUG_PLAYER_NOT_SEEABLE := false
# ; npc
var DEBUG_NPC_SHOW_HEALTH_BAR := false
var DEBUG_NPC_SHOW_NAME := false
var DEBUG_NPC_AI_DRAW_NAV_PATH := false
var DEBUG_NPC_AI_SHOW_TARGET := false
var DEBUG_NPC_AI_SHOW_STATE := false
# ; town
var DEBUG_SHOW_NAVMAP := false
var DEBUG_SHOW_SIGHT_OCCLUSION := false
var DEBUG_SHOW_CASE_VISUALS := false
var DEBUG_SHOW_WAYPOINTS := false
var DEBUG_SHOW_SPAWN_TILEMAP := false
# ; collision
var DEBUG_VISIBLE_COLLISION_SHAPES := false setget SET_DEBUG_VISIBLE_COLLISION_SHAPES
# ; shapes
# ; (these are enabled only if DEBUG_VISIBLE_COLLISION_SHAPES is enabled!)
var DEBUG_VISIBLE_NPC_COL_SHAPE := false
var DEBUG_VISIBLE_NPC_ATTACK_RANGE := false
var DEBUG_VISIBLE_NPC_SEE_RANGE := false
var DEBUG_VISIBLE_NPC_HEAR_RANGE := false
var DEBUG_VISIBLE_PLAYER_COL_SHAPE := false
var DEBUG_VISIBLE_PLAYER_ATTACK_RANGE := false
var DEBUG_VISIBLE_PLAYER_SEE_RANGE := false
var DEBUG_VISIBLE_PLAYER_HEAR_RANGE := false
var DEBUG_VISIBLE_PLAYER_USE_RANGE := false
var DEBUG_VISIBLE_AUDIO_SOURCE_RANGE := false
# ; ui
var DEBUG_SHOW_DEBUG_OVERLAY := false

# [editor]
var is_editor_enabled := true

################################################################################
## CONFIG GETTERS

func is_using_mouse_input() -> bool:
	return input_mode == Global.CONTROL_SCHEME.MOUSE

func is_using_keyboard_input() -> bool:
	return input_mode == Global.CONTROL_SCHEME.KEYBOARD

func is_using_hybrid_input() -> bool:
	return input_mode == Global.CONTROL_SCHEME.HYBRID

################################################################################
## CONFIG SETTERS

func set_input_mode(value : int): # int : Global.CONTROL_SCHEME
	input_mode = value
	emit_signal("input_mode_changed")

func set_master_volume(value : float):
	master_volume = value
	var volume_db : float = 20*log(float(value)/100.0)/log(10.0)
	# -INF (when new_value = 0) doesn't seem to pose any issues!
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)

func set_mute_master(value : bool):
	mute_master = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), value)

func set_music_volume(value : float):
	music_volume = value
	var volume_db : float = 20*log(float(value)/100.0)/log(10.0)
	# -INF (when new_value = 0) doesn't seem to pose any issues!
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume_db)

func set_mute_music(value : bool):
	mute_music = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), value)

func set_sfx_volume(value : float):
	sfx_volume = value
	var volume_db : float = 20*log(float(value)/100.0)/log(10.0)
	# -INF (when new_value = 0) doesn't seem to pose any issues!
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), volume_db)

func set_mute_sfx(value : bool):
	mute_sfx = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), value)

func set_ambient_sound_volume(value : float):
	ambient_sound_volume = value
	var volume_db : float = 20*log(float(value)/100.0)/log(10.0)
	# -INF (when new_value = 0) doesn't seem to pose any issues!
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambient"), volume_db)

func set_mute_ambient_sound(value : bool):
	mute_ambient_sound = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Ambient"), value)

func set_show_version(value : bool):
	show_version = value
	emit_signal("version_visibility_changed")

func set_fullscreen(value : bool):
	fullscreen = value
	OS.window_fullscreen = value

func SET_DEBUG_VISIBLE_COLLISION_SHAPES(value : bool):
	DEBUG_VISIBLE_COLLISION_SHAPES = value
	if value:
		if DEBUG_ENABLED:
			get_tree().set_debug_collisions_hint(true)
	else:
		get_tree().set_debug_collisions_hint(false)
