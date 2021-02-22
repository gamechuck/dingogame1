class_name classTown, "res://assets/textures/class_icons/classTown.png"
extends Node2D

################################################################################
## CONSTANTS

#const SCENE_CASE_VISUAL := preload("res://src/cases/CaseVisual.tscn")
#const SCENE_AUDIO_SOURCE_VISUAL := preload("res://src/misc/AudioSourceVisual.tscn")
const SCENE_PLAYER := preload("res://src/game/characters/Player.tscn")
#const CHARACTER_SCENES := {
#	"villager": preload("res://src/game/characters/npcs/Villager.tscn"),
#	"mayor": preload("res://src/game/characters/npcs/Mayor.tscn")
#}

################################################################################
## PUBLIC VARIABLES

# keeps reference to its own town state
#var town_state : classTownState

#var npc_groups_alive : Dictionary setget set_npc_groups_alive
#func set_npc_groups_alive(v : Dictionary) -> void:
#	set_npc_groups_alive_v2(v)
#
#func set_npc_groups_alive_v1(v : Dictionary) -> void:
#	var npc_groups : Dictionary = v.duplicate(true)
#	var npc_groups_town : Dictionary = Flow.get_town_data(State.town_id, "npc_groups", {})
#
#	for npc_group_id in npc_groups.keys():
#		var npc_group : Dictionary = npc_groups[npc_group_id]
#		var npc_group_town : Dictionary = npc_groups_town.get(npc_group_id, {})
#		# replace -1 npc counts with default ones
#		for npc in npc_group.get("npcs", []):
#			if npc.count == -1:
#				var npcs_town : Array = npc_group_town.get("npcs", [])
#				for npc_town in npcs_town:
#					if npc_town.type == npc.type:
#						npc.count = npc_town.get("count", 0)
#		# append waypoint groups
#		npc_group.waypoint_groups = npc_group_town.waypoint_groups
#
#	npc_groups_alive = npc_groups
#
#func set_npc_groups_alive_v2(v : Dictionary) -> void:
#	var npc_groups_town : Dictionary = Flow.get_town_data(State.town_id, "npc_groups", {})
#	var npc_groups : Dictionary = v.duplicate(true)
#
#	npc_groups_alive.clear()
#	npc_groups_alive = npc_groups_town.duplicate(true)
#
#	for npc_group_id in npc_groups.keys():
#		var npc_group : Dictionary = npc_groups[npc_group_id]
#
#		if npc_groups_alive.has(npc_group_id):
#			# override with context group
#			var npc_group_alive = npc_groups_alive[npc_group_id]
#			if npc_group.has("waypoint_groups"):
#				npc_group_alive["waypoint_groups"] = npc_group["waypoint_groups"]
#			if npc_group.has("npcs"):
#				var npcs_alive = npc_group_alive["npcs"]
#				var npcs = npc_group["npcs"]
#
#				# override npc counts
#				for npc_alive in npcs_alive:
#					for npc in npcs:
#						if npc.get("type", "_") == npc_alive.get("type", ".") and npc.get("count", -1) != -1:
#							npc_alive["count"] = npc["count"]
#		else:
#			# append context group
#			npc_groups_alive[npc_group_id] = npc_group

################################################################################
## PRIVATE VARIABLES

onready var _players := $Sorted/Characters/Players
onready var _npcs := $Sorted/Characters/NPCs
onready var _interactables_root := $Sorted/Objects
#onready var _interactables_tilemap := $Sorted/InteractablesTileMap
#onready var _navigation := $Misc/Navigation
#onready var _nav_map := $Misc/Navigation/NavMap
#onready var _case_visuals := $Misc/CaseVisuals
#onready var _audio_source_visuals := $Misc/AudioSourceVisuals
#onready var _waypoint_manager := $Misc/WaypointManager
onready var _player_spawn_point := $Misc/PlayerSpawnPoint
#onready var _sight_occlusion_tilemap := $Misc/SightOcclusionTilemap

# ray casted when getting navpath
#onready var _waypoint_ray := $Misc/WaypointRay
var _interactables := []

# stores navpath requests that NPCs requested;
# these are processed once every frame so there's no lag
# in meantime, NPCs just wait for their request to get processed
#var _navpath_request_queue := []
#
#var _current_day_phase : int = State.DAY_STATE.DAY
#var _dawn_color := Color(0.8, 0.8, 0.8, 1.0)
#var _day_color := Color(0.8, 0.8, 0.8, 1)
#var _dusk_color := Color(0.8, 0.8, 0.8, 1)
#var _night_color := Color(0.8, 0.8, 0.8, 1)
#var _current_color := Color(0.8, 0.8, 0.8, 1)
#var _can_fade_day_phase := false
#var _fade_speed_ratio := 0.05

################################################################################
## SIGNALS

signal npc_count_alive_changed
signal game_won
signal game_lost

################################################################################
## GODOT CALLBACKS

func _ready():
#	town_state = State.get_town_state_by_id(State.town_id)
#	_interactable_data =
#	set_npc_groups_alive(town_state.npc_groups)
#	_setup_day_phase()
	_spawn_level()
	_spawn_npcs()
	_spawn_player()
	_spawn_interactables()
	_connect_signals()
#	_apply_debug_settings()

#	_navigation.remove_child(_nav_map)
#	_nav_map.queue_free()

	State.set_loaded_town(self)

#func _process(_delta : float) -> void:
#	_update_case_visuals()
	# process single navpath request
#	if _navpath_request_queue.size() > 0:
#		var navpath_request : classNavpathRequest = _navpath_request_queue.pop_front()
#		navpath_request.requester.nav_path = _get_nav_path_between_positions(navpath_request.pos_start, navpath_request.pos_end, navpath_request.ignore_waypoints)

################################################################################
## PUBLIC FUNCTIONS

## FETCHING

func get_player() -> classPlayer:
	return _players.get_child(0) as classPlayer

#func get_player_by_index(index : int) -> classPlayer:
#	return _players.get_child(index) as classPlayer
#
#func get_random_waypoint_from_group(waypoint_group : String) -> classWaypoint:
#	var waypoints = get_tree().get_nodes_in_group("waypoint_" + waypoint_group)
#	return waypoints[randi() % waypoints.size()]

## NPCS
#
#func get_npc_count(groups : Dictionary, group_id : String, npc_type : String) -> int:
#	var group : Dictionary = groups.get(group_id, {})
#	for npc in group.get("npcs", []):
#		if npc.type == npc_type:
#			return npc.get("count", -1)
#	return -1

#func get_npc_count_alive_by_type(npc_type : String) -> int:
#	var count := 0
#	for group in npc_groups_alive.values():
#		for npc in group.get("npcs", []):
#			if npc.type == npc_type:
#				count += npc.count
#	return count
#
#func get_npc_count_alive_by_group(group_id : String) -> int:
#	var count := 0
#	var group : Dictionary = npc_groups_alive.get(group_id, {})
#	for npc in group.get("npcs", []):
#		count += npc.count
#	return count
#
#func get_npc_count_alive() -> int:
#	var count := 0
#	for group in npc_groups_alive.values():
#		for npc in group.get("npcs", []):
#			count += npc.count
#	return count
#
#func get_npc_count_alive_for_mission() -> int:
#	var count := 0
#
#	var win_conditions : Array = town_state.get_win_conditions()
#	for win_condition in win_conditions:
#		match win_condition:
#			"kill_all":
#				count = get_npc_count_alive()
#			"kill_mayor":
#				count = get_npc_count_alive_by_type("mayor")
#
#	return count
#
#func reduce_npc_count_alive(group_id : String, npc_type : String) -> void:
##	print("Reducing '{0}' of group with id '{1}'".format([npc_type, group_id]))
#	var group : Dictionary = npc_groups_alive.get(group_id, {})
#	for npc in group.get("npcs", []):
#		if npc.type == npc_type:
#			npc.count -= 1
#			break

	# check if game won
#	var won := true
#	for win_condition in town_state.get_win_conditions():
#			match win_condition:
#				"kill_mayor":
#					if get_npc_count_alive_by_type("mayor") > 0:
#						won = false
#						break
#				"kill_all":
#					if get_npc_count_alive() > 0:
#						won = false
#						break
#	if won:
##		emit_signal("game_won")
#
#################################################################################
### PRIVATE FUNCTIONS
#
#func _apply_debug_settings() -> void:
#	var show_navmap : bool = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_SHOW_NAVMAP
#	# sometimes people disable both nodes so this makes sure both are updated
#	_navigation.visible = show_navmap
#	_nav_map.visible = false
#
#	_case_visuals.visible = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_SHOW_CASE_VISUALS
#
#	var show_waypoints : bool = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_SHOW_WAYPOINTS
#	_waypoint_manager.visible = show_waypoints
#	_player_spawn_point.visible = show_waypoints
#
#	_interactables_tilemap.visible = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_SHOW_SPAWN_TILEMAP
#	_interactables_tilemap.modulate = Color(1.0, 0.1, 0.1, 0.5)
#
#	_sight_occlusion_tilemap.visible = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_SHOW_SIGHT_OCCLUSION

func _connect_signals() -> void:
	var bells := get_tree().get_nodes_in_group("bells")
	var players := get_tree().get_nodes_in_group("players")
	var characters := get_tree().get_nodes_in_group("characters")
	var npcs := get_tree().get_nodes_in_group("npcs")

	# bells
	for bell in bells:
		bell.connect("activated", self, "_on_bell_activated")
		bell.connect("deactivated", self, "_on_bell_deactivated")

	# players
	for player in players:
		player.connect("died", self, "_on_player_died")
		player.connect("overlay_update_requested", State, "_on_player_overlay_update_requested")

	# characters
	for character in characters:
		character.connect("closest_object_requested", self, "_on_closest_object_requested", [character])
		character.connect("nav_path_to_target_requested", self, "_on_nav_path_to_target_requested", [character])
		character.connect("nav_path_to_position_requested", self, "_on_nav_path_to_position_requested", [character])
		character.connect("random_waypoint_requested", self, "_on_character_random_waypoint_requested", [character])
		character.connect("audio_source_spawn_requested", self, "_on_audio_source_spawn_requested")

	# mouse detectors -> players
	for mouse_detector in get_tree().get_nodes_in_group("mouse_detectors"):
		for player in players:
			mouse_detector.connect("mouse_entered", player, "_on_mouse_detector_mouse_entered", [mouse_detector])
			mouse_detector.connect("mouse_exited", player, "_on_mouse_detector_mouse_exited")

	# npcs
	for npc in npcs:
		npc.connect("died", self, "_on_npc_died", [npc])

#	connect("npc_count_alive_changed", State, "_on_npc_count_alive_changed")
#	connect("game_won", State, "_on_game_won")
#	connect("game_lost", State, "_on_game_lost")

## SPAWNING
func _spawn_level() -> void:
	pass

func _spawn_player() -> void:
#	var player := SCENE_PLAYER.instance()
#	_players.add_child(player)
#
#	var player_state : Dictionary = town_state.player_state
#
#	# position
#	var player_position_array : Array = player_state.get("position", [])
#	if player_position_array.size() == 2:
#		player.global_position = Vector2(player_position_array[0], player_position_array[1])
#	else:
#		var player_spawn_point = $Misc/PlayerSpawnPoint
#		player.global_position = player_spawn_point.global_position
#
#	# hp
#	var hp = player_state.get("hp", -1)
#	if hp != -1:
#		player.set_hp(hp)
	pass

func _spawn_npcs() -> void:
#	var npc_groups_town : Dictionary = Flow.get_town_data(State.town_id, "npc_groups", {})
#	var npc_groups_final := npc_groups_town.duplicate(true)
#	var npc_groups_context : Dictionary = town_state.npc_groups
#
#	for npc_group_id in npc_groups_context.keys():
#		var npc_group : Dictionary = npc_groups_context[npc_group_id]
#
#		if npc_groups_final.has(npc_group_id):
#			# override with context group
#			var npc_group_final = npc_groups_final[npc_group_id]
#			if npc_group.has("waypoint_groups"):
#				npc_group_final["waypoint_groups"] = npc_group["waypoint_groups"]
#			if npc_group.has("npcs"):
#				var npcs_final = npc_group_final["npcs"]
#				var npcs = npc_group["npcs"]
#
#				# override npc counts
#				for npc_final in npcs_final:
#					for npc in npcs:
#						if npc.get("type", "_") == npc_final.get("type", ".") and npc.get("count", -1) != -1:
#							npc_final["count"] = npc["count"]
#		else:
#			# append context group
#			npc_groups_final[npc_group_id] = npc_group
#
#	# actual spawning
#	for npc_group_id in npc_groups_final.keys():
#		var npc_group : Dictionary = npc_groups_final.get(npc_group_id, {})
#
#		# fetch waypoints
#		var waypoint_group_ids : Array = npc_group.get("waypoint_groups", [])
#
#		var npcs_dict_array = npc_group.get("npcs", [])
#		# spawn npcs and apply data
#		for npc_data in npcs_dict_array:
#			var npc_type = npc_data.get("type", "")
#			if not npc_type in CHARACTER_SCENES.keys():
#				continue
#
#			var day_phase_states = {}
#			day_phase_states["day_states"] = npc_data.get("day_states", ["PATROL"])
#			day_phase_states["night_states"] = npc_data.get("night_states", ["PATROL"])
#
#			for i in npc_data["count"]:
#				var npc = CHARACTER_SCENES[npc_type].instance()
#				npc.set_day_phase_starting_states(day_phase_states)
#
#				npc.npc_group_id = npc_group_id
#				npc.waypoint_group_ids = waypoint_group_ids
#
#				# apply properties
#				var properties : Dictionary = npc_data.get("properties", {})
#				for property in properties.keys():
#					npc.set(property, properties[property])
#
#				_npcs.add_child(npc, true)
#
#				# position npc to random position of its waypoint group
#				var group_id := ""
#				if npc.waypoint_group_ids.size() > 0:
#					group_id = npc.waypoint_group_ids[0]
#				var spawn_waypoint : classWaypoint = _waypoint_manager.get_random_waypoint(group_id)
#				if spawn_waypoint:
#					npc.global_position = spawn_waypoint.global_position
	pass

func _spawn_interactables() -> void:
#	for interactable_name in  Flow.interactable_data:
#		var interactable_entry : Dictionary =  Flow.interactable_data[interactable_name]
#		var tile_id = interactable_entry.get("tile_id")
#		var packed_scene : PackedScene =  load(interactable_entry["packed_scene"])
#		var parent : Node2D =  _interactables_root.get_node(interactable_entry["parent"])
#		var properties : Dictionary = interactable_entry.get("properties", {})
#		var loadable_properties = properties.get("load", {})
#		properties.erase("load")
#
#		for key in loadable_properties:
#			var load_path = loadable_properties.get(key)
#			properties[key] = load(load_path)
#
#		var tile_set : TileSet = _interactables_tilemap.tile_set
#		var tile_region := tile_set.tile_get_region(tile_id)
#
#		for tile_position in _interactables_tilemap.get_used_cells_by_id(tile_id):
#			var interactable := packed_scene.instance()
#			parent.add_child(interactable)
#
#			var offset : Vector2 = Vector2.ZERO
#			if interactable is classInteractable:
#				offset = interactable.spawn_offset
#
#			for key in properties.keys():
#				var value = properties[key]
#				interactable.set(key, value)
#
#			interactable.global_position = (tile_position * 32.0) + offset
#			interactable.global_position += (tile_region.size * 0.5)
#			interactable.connect("audio_source_spawn_requested", self, "_on_audio_source_spawn_requested")
#			_interactables.append(interactable)
	pass

## NAVIGATION
# returns array of positions that leads from pos_start to pos_end
#func _get_nav_path_between_positions(pos_start : Vector2, pos_end : Vector2, ignore_waypoints := false) -> PoolVector2Array:
#	var path := PoolVector2Array()
#
#	# use only navmesh if ignoring waypoints
#	if ignore_waypoints:
#		path = _navigation.get_simple_path(pos_start, pos_end, true)
#		if path.size() > 0:
#			path.remove(0) # remove initial position
#		return path
#
#	# grab closest non-obscured waypoint to pos_start
#	var waypoint_id_start := 0
#	var waypoint_start : classWaypoint
#	_waypoint_manager.set_points_disabled(false)
#	while true:
#		waypoint_id_start = _waypoint_manager.astar.get_closest_point(pos_start)
#		if waypoint_id_start == -1:
#			push_error("failed to find reachable starting waypoint from position " + str(pos_start) + "!")
#			return PoolVector2Array()
#		waypoint_start = _waypoint_manager.get_waypoint_or_null(waypoint_id_start)
#		var pos_waypoint := waypoint_start.global_position
#		# if no NAV_SOLID between, continue
#		if not _has_nav_solid_between_positions(pos_start, pos_waypoint):
#			break
#		# otherwise look for another waypoint
#		_waypoint_manager.astar.set_point_disabled(waypoint_id_start, true)
#
#	# grab closest waypoint to pos_end
#	var waypoint_id_end : int = _waypoint_manager.astar.get_closest_point(pos_end)
#	var waypoint_end : classWaypoint = _waypoint_manager.get_waypoint_or_null(waypoint_id_end)
#
#	# grab closest non-obscured waypoint to pos_end
##	var waypoint_id_end := 0
##	var waypoint_end : classWaypoint
##	_waypoint_manager.set_points_disabled(false)
##	while true:
##		waypoint_id_end = _waypoint_manager.astar.get_closest_point(pos_end)
##		if waypoint_id_end == -1:
##			push_error("failed to find reachable ending waypoint from position " + str(pos_end) + "!")
##			return PoolVector2Array()
##		waypoint_end = _waypoint_manager.get_waypoint_or_null(waypoint_id_end)
##		var pos_waypoint := waypoint_end.global_position
##		# if no NAV_SOLID between, continue
##		if not _has_nav_solid_between_positions(pos_end, pos_waypoint):
##			break
##		# otherwise look for another waypoint
##		_waypoint_manager.astar.set_point_disabled(waypoint_id_end, true)
#
#	# get path between waypoints
#	_waypoint_manager.set_points_disabled(false)
#	path = _waypoint_manager.get_path_between_waypoint_ids(waypoint_id_start, waypoint_id_end)
#	if path.size() > 0:
#		# remove initial position
#		path.remove(0)
#	else:
#		push_warning("couldn't find path between waypoints " + waypoint_start.name + " and " + waypoint_end.name)
#		return PoolVector2Array()
#
#	# append navmesh path from pos_start to waypoint_start
#	# (skip if already close enough)
#	var distance_to_waypoint_start := ((pos_start - waypoint_start.global_position) as Vector2).length()
#	if distance_to_waypoint_start > 20.0:
#		var path_start = _navigation.get_simple_path(pos_start, waypoint_start.global_position, true)
#		if path_start.size() > 0:
#			path_start.remove(0) # remove initial position
#		path = path_start + path
#
#	# append navmesh path from waypoint_end to pos_end
#	var path_end = _navigation.get_simple_path(waypoint_end.global_position, pos_end, true)
#	if path_end.size() > 0:
#		path_end.remove(0) # remove initial position
#	path = path + path_end
#
#	return path

# helper func for _get_nav_path_between_positions()
#func _has_nav_solid_between_positions(pos_start : Vector2, pos_end : Vector2) -> bool:
#	_waypoint_ray.global_position = pos_start
#	_waypoint_ray.cast_to = pos_end - pos_start
#	_waypoint_ray.force_raycast_update()
#	return _waypoint_ray.get_collider() != null

#func _get_closest_target_to_object(object : Node2D, target_group : String) -> Node2D:
#	return Flow.get_closest_object(object, get_tree().get_nodes_in_group(target_group))
#
#func _push_navpath_request(requester : Node2D, pos_start : Vector2, pos_end : Vector2, ignore_waypoints : bool) -> void:
#	var navpath_request := classNavpathRequest.new()
#	navpath_request.requester = requester
#	navpath_request.pos_start = pos_start
#	navpath_request.pos_end = pos_end
#	navpath_request.ignore_waypoints = ignore_waypoints
##	print("Object " + requester.name + " requested path to: " + target.name + ". Ignoring wp: " + str(ignore_waypoints))
#	_navpath_request_queue.push_back(navpath_request)

## CASE SYSTEM
#
#func _update_case_visuals() -> void:
#	# update current visuals
#	for case_visual in _case_visuals.get_children():
#		var investigation : classInvestigation = case_visual.investigation
#		if investigation == null:
#			_case_visuals.remove_child(case_visual)
#			case_visual.queue_free()
#		else:
#			if investigation.closed:
#				_case_visuals.remove_child(case_visual)
#				case_visual.queue_free()
#			case_visual.position = investigation.location
#	# create new visuals
#	for case in State.case_manager.cases:
#		for investigation in case.investigations:
#			if investigation.closed:
#				continue
#			if _case_visual_has_investigation(investigation):
#				continue
#			# we don't have this investigation
#			# TODO: merge near ones?
#			# ...
#			# create new visual
#			var case_visual := SCENE_CASE_VISUAL.instance()
#			case_visual.name = "CaseVisual"
#			case_visual.position = investigation.location
#			case_visual.investigation = investigation
#			_case_visuals.add_child(case_visual, true)
#
#func _case_visual_has_investigation(investigation : classInvestigation) -> bool:
#	for case_visual in _case_visuals.get_children():
#		if case_visual.investigation.case_type == investigation.case_type and\
#				case_visual.investigation.investigator_name == investigation.investigator_name:
#			return true
#	return false

## DAY-NIGHT
#
#func _setup_day_phase() -> void:
#	var temp = town_state.day_phase_state.get("dawn_color")
#	_dawn_color = Color(temp[0], temp[1], temp[2], temp[3])
#	temp = town_state.day_phase_state.get("day_color")
#	_day_color = Color(temp[0], temp[1], temp[2], temp[3])
#	temp = town_state.day_phase_state.get("dusk_color")
#	_dusk_color = Color(temp[0], temp[1], temp[2], temp[3])
#	temp = town_state.day_phase_state.get("night_color")
#	_night_color = Color(temp[0], temp[1], temp[2], temp[3])
#	_fade_speed_ratio =  clamp(town_state.day_phase_state.get("fade_speed_ratio"), 0.0, 1.0)
#
#func _set_day_shader_color(color : Color) -> void:
#	material.set_shader_param("red_scale", color.r)
#	material.set_shader_param("green_scale", color.g)
#	material.set_shader_param("blue_scale", color.b)
#	material.set_shader_param("decolorization", color.a)
#

################################################################################
## SIGNAL CALLBACKS
#
#func _on_bell_activated(bell : classBell) -> void:
#	for npc in _npcs.get_children():
#		npc._on_bell_activated(bell)
#	AudioEngine.play_music("town_vigilant")
#
#func _on_bell_deactivated(bell : classBell) -> void:
#	for npc in _npcs.get_children():
#		npc._on_bell_deactivated(bell)
#	pass
#	AudioEngine.play_music("town_idle")

func _on_player_died() -> void:
	for npc in _npcs.get_children():
		npc._on_interrupt_player_died()
	emit_signal("game_lost")

func _on_npc_died(npc : classNPC) -> void:
#	reduce_npc_count_alive(npc.npc_group_id, npc.type)
	emit_signal("npc_count_alive_changed")
#
#func _on_audio_source_spawn_requested(source_owner : Node2D, spawn_position : Vector2, source_data : Dictionary) -> void:
#	if not source_data or source_data.size() < 1:
#		print("Town: audio source spawn requested, but no sourc data provided!")
#		return
#
#	var audio_detectors = get_tree().get_nodes_in_group("audio_detector")
#	var noise_radius = source_data.get("noise", 0.0)
#
#	if ConfigData.DEBUG_VISIBLE_AUDIO_SOURCE_RANGE:
#		var audio_source : StaticBody2D = SCENE_AUDIO_SOURCE_VISUAL.instance()
#		audio_source.global_position = spawn_position
#		_audio_source_visuals.add_child(audio_source)
#		audio_source.get_node("SoundRadius").shape.set_radius(noise_radius)
#	for audio_detector in audio_detectors:
#		var distance = audio_detector.global_position.distance_to(spawn_position)
#		if distance < noise_radius and audio_detector.get_parent() != source_owner:
#			audio_detector.on_audio_source_detected(source_owner, spawn_position, source_data)

## NAVIGATION

#func _on_closest_object_requested(target_group : String, requester : Node2D):
#	requester.set_target(_get_closest_target_to_object(requester, target_group))
#
#func _on_nav_path_to_closest_object_requested(target_group : String, ignore_waypoints : bool, requester : Node2D):
#	var target : Node2D = _get_closest_target_to_object(requester, target_group)
#	if target:
#		_push_navpath_request(requester, requester.global_position, target.global_position, ignore_waypoints)
#
#func _on_nav_path_to_target_requested(target : Node2D, ignore_waypoints : bool, requester : Node2D) -> void:
#	_push_navpath_request(requester, requester.global_position, target.global_position, ignore_waypoints)
#
#func _on_nav_path_to_position_requested(pos : Vector2, ignore_waypoints : bool, requester : Node2D) -> void:
#	_push_navpath_request(requester, requester.global_position, pos, ignore_waypoints)
#
#func _on_character_random_waypoint_requested(requester : Node2D) -> void:
#	var group_id := ""
#	if requester.waypoint_group_ids.size() > 0:
#		group_id = requester.waypoint_group_ids[0]
#	requester.set_target(_waypoint_manager.get_random_waypoint(group_id))
#
### DAY-NIGHT
#func _on_day_phase_updated(day_state : int) -> void:
#	var fade_speed = 0.0
#	var _previous_color := Color(material.get_shader_param("red_scale"), material.get_shader_param("green_scale"), material.get_shader_param("blue_scale"), material.get_shader_param("decolorization"))
#
#	match day_state:
#		State.DAY_STATE.DAWN:
#			_current_color = _dawn_color
#			fade_speed = _fade_speed_ratio * State.get_dawn_duration()
#		State.DAY_STATE.DAY:
#			_current_color = _day_color
#			fade_speed = _fade_speed_ratio * State.get_dawn_duration()
#		State.DAY_STATE.DUSK:
#			_current_color = _dusk_color
#			fade_speed = _fade_speed_ratio * State.get_dusk_duration()
#		State.DAY_STATE.NIGHT:
#			_current_color = _night_color
#			fade_speed = _fade_speed_ratio  * State.get_dusk_duration()
#
#	_current_day_phase = day_state
#	$Tween.interpolate_method(self, "_set_day_shader_color", _previous_color, _current_color, fade_speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
#	$Tween.start()
#

