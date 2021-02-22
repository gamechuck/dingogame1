class_name classNPC
extends classCharacter

################################################################################
## CONSTANTS

var PANIC_SHAKE_FACTOR := 1.0

# makes alerting move faster/slower
var ALERTNESS_BASE_FACTOR := ConfigData.NPC_ALERTNESS_BASE_FACTOR
# defines range where alertness modifies based on distance
# (these are coupled to collision shape so not exporting them)
var ALERTNESS_DISTANCE_FACTOR_MIN := 0.5
var ALERTNESS_DISTANCE_FACTOR_MIN_DISTANCE := 40.0
var ALERTNESS_DISTANCE_FACTOR_MAX_DISTANCE := 120.0
# defines how fast it takes for NPC to hear player
var ALERTNESS_PLAYER_HEARD_FACTOR := 6.0
var ALERTNESS_DECREASE_FACTOR := -0.15


################################################################################
## PUBLIC VARIABLES

# override this for implemented NPCs
var type := ""
var alerted := false
var show_alertness_icon := true

var alertness := 0.0 setget set_alertness
func set_alertness(v : float) -> void:
	alertness = clamp(v, 0.0, 1.0)

	if _alertness_bar:
		_alertness_bar.value = alertness
	if _alertness_icon:
		if _alertness_icon.animation == "suspicious":
			if alertness == 0.0:
				_alertness_icon.visible = false
			else:
				if show_alertness_icon:
					_alertness_icon.visible = true
				_alertness_icon.scale = Vector2.ONE * alertness
		else:
			_alertness_icon.scale = Vector2.ONE

# when not alert, defines if weapon should be kept in inventory or not
var keep_weapon := false setget , get_keep_weapon
func get_keep_weapon() -> bool:
	return keep_weapon

# if true, NPC will not hide nor go ring the bell
var brave := false setget , get_brave
func get_brave() -> bool:
	return brave

# if true, NPC spawns with a weapon
var spawn_with_weapon := false setget , get_spawn_with_weapon
func get_spawn_with_weapon() -> bool:
	return spawn_with_weapon

# ignores cases with priority above this one
var max_case_priority := 99

################################################################################
## PRIVATE VARIABLES

onready var _alertness_bar := $GUI/AboveHead/AlertnessBar
onready var _state_label := $GUI/AboveHead/StateLabel
onready var _target_label := $GUI/AboveHead/TargetLabel
onready var _alertness_icon := $AlertnessIcon
onready var _alertness_icon_tween := $AlertnessIcon/Tween
onready var _vision_cone := $SeeRange/VisionCone
onready var _alert_enter := $SFX/AlertEnter
onready var _sabotage_bar := $SabotageGUI/ProgressBar

# BT state
# do not modify directly; use set_next_state() to trigger state transition
#var _state := ""
#func set_state(v : String) -> void:
#	_state = v
#	#
#	_state_label.text = "S: " + v

# BT next state; empty by default
#var _next_state := ""
#func set_next_state(v : String) -> void:
#	# do not set new state if it's already set!
#	if _next_state != "":
#		return
#
#	_next_state = v

# override
#func set_investigated(v : bool) -> void:
#	.set_investigated(v)
#	_current_direction = Global.DIRECTION.E
#	_play_animation(classCharacterAnimations.ANIMATION_TYPE.DEATH_INVESTIGATED)

#var _brain_state : classBrainState
#var _interrupts := []
#
#var _case_type := ""
#var _case_target_name := ""
#
#var _current_day_phase := 0
#var _day_starting_states = []
#var _night_starting_states = []
#
#var _last_weapon_container = null
#var _has_wood_in_hand = false
#var _has_sabotage_target := false
#var _is_fixing_sabotage := false
#var _last_found_sabotaged : Node2D = null
#var _fix_start_time := 0.0
#var _is_patrol_idle_animation_playing := false
#var _patrol_animations := {}
#onready var _sfx_death_samples := []
#onready var _sfx_attack_samples := []
#onready var _sfx_footsteps := {}
#onready var _blood_spatter_scene := preload("res://src/particles/BloodSpatter.tscn")

################################################################################
## GODOT CALLBACKS
func _ready() -> void:
	add_to_group("npcs")
	_setup_data()
#	_setup_brain_state()
#	set_state(Flow.get_default_brain_state_for(type))
#	_set_brain_for_current_state()
#	_set_interrupts_for_current_state()
	set_movement_speed(ConfigData.NPC_WALK_SPEED)
#	self.alertness = alertness
	set_hp_max(9)
	set_hp(hp_max, true)

#	if spawn_with_weapon:
#		_set_item(classItem.new())

	# setup sfx
#	_sfx_attack.stream = _sfx_attack_samples[randi() % _sfx_attack_samples.size()]
#	_knockback_start_speed = ConfigData.PLAYER_START_KNOCKBACK_SPEED

	# connect signals
#	connect("object_seen", self, "_on_object_seen")
#	connect("object_seen", self, "_on_interrupt_object_seen")
#	connect("target_not_seen", self, "_on_interrupt_target_not_seen")
#	connect("died", self, "_on_died")
#	$SabotageDetectRange.connect("body_entered", self, "_on_sabotage_detect_range_body_entered")
#	State.connect("day_phase_updated", self, "_on_day_phase_updated")
#
#	# debug
#	if ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_NPC_SHOW_HEALTH_BAR:
#		_hp_bar.visible = true
#	if ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_NPC_SHOW_NAME:
#		_name_label.visible = true
#	if ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_NPC_AI_SHOW_STATE:
#		_state_label.visible = true
#	if ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_NPC_AI_SHOW_TARGET:
#		_target_label.visible = true
#	if ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_NPC_AI_DRAW_NAV_PATH:
#		_debug_draw_nav_path = true
	# debug / shapes
	_collision.visible = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_VISIBLE_COLLISION_SHAPES and ConfigData.DEBUG_VISIBLE_NPC_COL_SHAPE
#	_attack_range.visible = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_VISIBLE_COLLISION_SHAPES and ConfigData.DEBUG_VISIBLE_NPC_ATTACK_RANGE
#	_see_range.visible = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_VISIBLE_COLLISION_SHAPES and ConfigData.DEBUG_VISIBLE_NPC_SEE_RANGE
#	_hear_range.visible = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_VISIBLE_COLLISION_SHAPES and ConfigData.DEBUG_VISIBLE_NPC_HEAR_RANGE

func _physics_process(delta : float) -> void:
	if alive:
		pass
#		_brain_state.execute(delta)
#
#		# update state label
#		var s := "target = "
#		if _target:
#			s += _target.name
#		else:
#			s += "x"
#		_target_label.text = s
#
#		if _is_knocked_back:
#			_knock_back()
#			return
#
#		# shake if panicking
#		if panicking:
#			_animated_sprite.position.x = rand_range(-PANIC_SHAKE_FACTOR, PANIC_SHAKE_FACTOR)
#			_animated_sprite.position.y = rand_range(-PANIC_SHAKE_FACTOR, 0.0)
#		else:
#			_animated_sprite.position = Vector2.ZERO
#
#		# temp set speed in states
#		match _state:
#			"PATROL", "DROP_WEAPON", "GATHER_WOOD", "KEEP_FIRE":
#				set_movement_speed(ConfigData.NPC_WALK_SPEED)
#			_:
#				set_movement_speed(ConfigData.NPC_RUN_SPEED)
#
#		# temp look at player when hunting him
#		match _state:
#			"HUNT_TARGET":
#				_look_at_target = true
#			_:
#				_look_at_target = false
#
#		# temp decrease alertedness
#		match _state:
#			"PATROL", "DROP_WEAPON", "SEEK_SHELTER", "HIDDEN":
#				_change_alertedness_by(ALERTNESS_DECREASE_FACTOR)
#
#		match _state:
#			"HUNT_TARGET":
#				hunting_target = true
#			_:
#				hunting_target = false
#		match _state:
#			"FIX_SABOTAGE":
#				set_movement_speed(ConfigData.NPC_WALK_SPEED)
#				if _is_fixing_sabotage:
#					_update_sabotage_fix(delta)
#		_update_state()
#		_update_move_sfx_dict()
#		if is_in_wheat:
#			set_movement_speed(ConfigData.NPC_WHEAT_MOVE_SPEED)
#	update()

#func _draw() -> void:
#	if alive:
#		if ConfigData.DEBUG_ENABLED:
#			if _debug_draw_nav_path and _using_navpath:
#				_draw_nav_path()

# INTERRUPTS
#
#func _on_interrupt_investigation_opened() -> void:
#	for interrupt in _interrupts:
#		if not interrupt["type"] == "investigation_opened": continue
#		set_active_patrol_idle_animation(false)
#		_has_wood_in_hand = false
#		_can_update_animations = true
#		set_next_state(Flow.get_state_from_weighted_list(interrupt["states"]))
#		break
#
#func _on_interrupt_sabotage_found(sabotaged_interactable : Node2D) -> void:
#	for interrupt in _interrupts:
#		if not interrupt["type"] == "sabotage_found":
#			continue
#		set_active_patrol_idle_animation(false)
#		_can_update_animations = true
#		_has_sabotage_target = true
#		_last_found_sabotaged = sabotaged_interactable
#		_has_wood_in_hand = false
#		set_next_state(Flow.get_state_from_weighted_list(interrupt["states"]))
#		break
#
#func _on_interrupt_object_seen(object : Node2D) -> void:
#	for interrupt in _interrupts:
#		if not interrupt["type"] == "object_seen": continue
#		if interrupt.has("group") and not object.is_in_group(interrupt["group"]):
#			continue
#		if interrupt.has("alive") and not object.alive == interrupt["alive"]:
#			continue
#		if interrupt.has("state") and not object._state == interrupt["state"]:
#			continue
#		if object.body_state == object.BODY_STATE.HUMAN and not object.is_sabotaging:
#			continue
#		set_active_patrol_idle_animation(false)
#		if _is_fixing_sabotage:
#			_cancel_fixing_sabotage()
#		_can_update_animations = true
#		_has_wood_in_hand = false
#		set_next_state(Flow.get_state_from_weighted_list(interrupt["states"]))
#		break
#
#func _on_interrupt_target_not_seen() -> void:
#	for interrupt in _interrupts:
#		if not interrupt["type"] == "target_not_seen": continue
#		set_next_state(Flow.get_state_from_weighted_list(interrupt["states"]))
#		break
#
#func _on_interrupt_timer_timeout(timer : Timer) -> void:
#	for interrupt in _interrupts:
#		if not interrupt["type"] == "timer_timeout": continue
#		if not interrupt["name"] == timer.name: continue
#		set_next_state(Flow.get_state_from_weighted_list(interrupt["states"]))
#		break
#	timer.get_parent().remove_child(timer)
#	timer.queue_free()
#
#func _on_interrupt_player_died() -> void:
#	for interrupt in _interrupts:
#		if not interrupt["type"] == "object_died": continue
#		if interrupt.has("group") and not interrupt["group"] == "players": continue
#		set_next_state(Flow.get_state_from_weighted_list(interrupt["states"]))
#		break
#
#func _on_interrupt_day_phase_updated() -> void:
#	for interrupt in _interrupts:
#		if not interrupt["type"] == "day_phase_updated":
#			continue
#		if not _has_wood_in_hand:
#			set_random_day_phase_state()
#		break

################################################################################
## PUBLIC FUNCTIONS
# override - make NPC remember last weapon container
#func set_day_phase_starting_states(day_phase_states : Dictionary) -> void:
#	_day_starting_states = day_phase_states.get("day_states", ["PATROL"])
#	_night_starting_states = day_phase_states.get("night_states", ["PATROL"])
#
#func set_random_day_phase_state() -> void:
#	var starting_states = []
#
#	if _current_day_phase == State.DAY_STATE.DAY:
#		starting_states = _day_starting_states.duplicate()
#	else:
#		starting_states = _night_starting_states.duplicate()
#
#	if starting_states == null or starting_states.size() < 1:
#		return
#
#	if starting_states.size() == 1:
#		set_next_state(starting_states[0])
#		return
#
#	starting_states.remove(starting_states.find(_state))
#	set_next_state(starting_states[randi() % starting_states.size()])
#
#func set_last_weapon_container_as_target():
#	set_target(_last_weapon_container)
#	_last_weapon_container = null
#
#func set_next_state_weighted(states_data : Dictionary) -> void:
#	set_next_state(Flow.get_state_from_weighted_list(states_data))
#
## Used by AI to put the weapon back where found,this also clears last weapon container
#func take_item_from(c : Node2D) -> void:
#	.take_item_from(c)
#	_last_weapon_container = c

func take_damage(value : float,  attacker : Node2D) -> void:
	.take_damage(value, attacker)
#	var blood_spatter = _blood_spatter_scene.instance()
#	add_child(blood_spatter)
#	blood_spatter.global_position = global_position
#	blood_spatter.rotation = global_position.angle_to(attacker.global_position)

func die() -> void:
	.die()
#	_sfx_death.stream = _sfx_death_samples[randi() % _sfx_death_samples.size()]
#	_sfx_death.play()


# CASE SYSTEM
#
#func open_investigation(case_type : String, target : Node2D, pos : Vector2) -> void:
#	# ignore case if its priority is higher than max priority
#	if Flow.get_case_priority(case_type) > max_case_priority:
#		return
#
#	State.case_manager.open_investigation(self, case_type, target, pos)
#	_on_interrupt_investigation_opened()
#
#func has_investigation() -> bool:
#	return State.case_manager.is_investigating_any_case(self)
#
#func close_investigation() -> void:
#	State.case_manager.close_investigation_by_type(self, _case_type, _case_target_name)
#
#func close_all_investigations() -> void:
#	State.case_manager.close_all_investigations(self)
#
#func fetch_investigation() -> void:
#	var case : classCase = State.case_manager.get_case(self)
#	_case_type = case.type
#	_case_target_name = case.target.name
#
#func mark_case_target_as_investigated() -> void:
#	State.case_manager.mark_target_as_investigated_by_type(self, _case_type, _case_target_name)
#
## called from AI
#func set_target_from_case() -> void:
#	var case : classCase = State.case_manager.get_case_by_type(_case_type, _case_target_name)
#	if case.has_investigation(self):
#		set_target(case.target)
#
## AI CHECKS
#func has_sabotage_target() -> bool:
#	return _has_sabotage_target and _last_found_sabotaged and not _last_found_sabotaged.pending_repairs and _last_found_sabotaged.is_sabotaged
#
#func is_done_fixing() -> bool:
#	return not _is_fixing_sabotage
#
#func case_needs_weapon() -> bool:
#	fetch_investigation()
#	return Flow.get_case_weapon_needed(_case_type)
#
#func has_wood_in_hand() -> bool:
#	return true
#
## AI ACTIONS
#func set_sabotaged_as_target() -> void:
#	if _last_found_sabotaged and not _last_found_sabotaged.pending_repairs:
#		_last_found_sabotaged.schedule_fixing()
#		set_target(_last_found_sabotaged)
#
#func start_fixing_sabotage() -> void:
#	_last_found_sabotaged.start_fixing(self)
#	_sabotage_bar.max_value = _last_found_sabotaged.sabotage_duration
#	_sabotage_bar.show()
#	_fix_start_time = 0.0
#	_is_fixing_sabotage = true
#
#func cancel_fixing_sabotage() -> void:
#	_cancel_fixing_sabotage()
#
#func request_nav_path_to_case_position(ignore_waypoints : bool) -> void:
#	var investigation : classInvestigation = State.case_manager.get_investigation(self)
#	if not investigation:
#		push_error("failed to request nav path due to non-existent investigation!")
#		return
#	request_nav_path_to_position(investigation.location, ignore_waypoints)
#
#func set_active_patrol_idle_animation(value : bool) -> void:
#	if value and not _is_attacking and not _is_fixing_sabotage and not _is_knocked_back and not hunting_target:
#		_is_patrol_idle_animation_playing = true
#		_can_update_animations = false
#		var animation_region = Global.WAYPOINT_REGION.DEFAULT
#		if _target is classWaypoint:
#			animation_region = _target.animation_region
#		elif last_target_waypoint:
#			animation_region = last_target_waypoint.animation_region
#		var animations = _patrol_animations.get(animation_region, [])
#		_animated_sprite.play(animations[rand_range(0, animations.size())])
#	else:
#		_is_patrol_idle_animation_playing = false
#		#_can_update_animations = true
#
## WOOD GATHER ACTIONS
#func has_any_wood_gather_spot_non_full() -> bool:
#	set_closest_non_full_as_target("wood_gather_spots")
#	return _target != null and _target is classWoodBox
#
#func has_any_wood_gather_spot_non_empty() -> bool:
#	set_closest_non_empty_as_target("wood_gather_spots")
#	return _target != null and _target is classWoodBox
#
#func request_closest_wood_pick_spot() -> void:
#	set_closest_object_as_target("wood_pick_spots")
#
#func request_closest_wood_gather_spot() -> void:
#	set_closest_non_full_as_target("wood_gather_spots")
#
#func request_closest_fireplace() -> void:
#	set_closest_object_as_target("fireplaces")
#
#func change_wood_amount(value : int) -> void:
#	if _target is classWoodBox:
#		_target.change_amount(value)
#
#func set_has_wood_in_hand(value : bool) -> void:
#	_has_wood_in_hand = value
#
#func play_work_animation(value : String) -> void:
#	_can_update_animations = false
#	_animated_sprite.play(value)

################################################################################
## PRIVATE FUNCTIONS

func _setup_data() -> void:
	pass
#	var sfx_movement_data = Flow.npcs_data.get("assets").get("movement_sfx", {})
#
#	for walk_mode_key in sfx_movement_data:
#		var sound_region_dict = sfx_movement_data.get(walk_mode_key)
#		var walk_mode_enum_value = Global.WALK_MODE.values()[Global.WALK_MODE.keys().find(walk_mode_key)]
#		_sfx_footsteps[walk_mode_enum_value] = {}
#
#		for sound_region_key in sound_region_dict:
#			var sound_region_enum_value = Global.SOUND_REGION.values()[Global.SOUND_REGION.keys().find(sound_region_key)]
#			var asset_path_array = sound_region_dict.get(sound_region_key)
#
#			_sfx_footsteps[walk_mode_enum_value][sound_region_enum_value] = []
#
#			for i in asset_path_array.size():
#				_sfx_footsteps.get(walk_mode_enum_value).get(sound_region_enum_value).append(load(asset_path_array[i]))
#
#	var patrol_animation_data = Flow.npcs_data.get("assets").get("patrol_animations", {})
#	for waypoint_region_key in patrol_animation_data:
#		var waypoint_region_enum = Global.WAYPOINT_REGION.values()[Global.WAYPOINT_REGION.keys().find(waypoint_region_key)]
#		var waypoint_animation_array = patrol_animation_data[waypoint_region_key]
#		_patrol_animations[waypoint_region_enum] = []
#		for i in range(waypoint_animation_array.size()):
#			_patrol_animations.get(waypoint_region_enum).append(waypoint_animation_array[i])
#			pass
#
#	var _sfx_attack_data = Flow.npcs_data.get("assets").get("attack_sfx", [])
#	for i in _sfx_attack_data.size():
#		_sfx_attack_samples.append(load(_sfx_attack_data[i]))
#
#	var _sfx_death_data = Flow.npcs_data.get("assets").get("death_sfx", [])
#	for i in _sfx_death_data.size():
#		_sfx_death_samples.append(load(_sfx_death_data[i]))
#
#	var _sfx_damaged_data = Flow.npcs_data.get("assets").get("damaged_sfx")
##	for i in _sfx_damaged_data.size():
#		_sfx_damaged_samples.append(load(_sfx_damaged_data[i]))
#
#func _setup_brain_state() -> void:
#	_brain_state = classBrainState.new()
#	_brain_state.name = "BrainState"
#	add_child(_brain_state)
#
#func _set_brain_for_current_state() -> void:
#	_brain_state.clear()
#	var _brain = Flow.get_brain(type, _state)
#	_brain_state.setup(_brain, self)
#	pass
#
#func _set_interrupts_for_current_state() -> void:
#	_interrupts = Flow.get_interrupts(type, _state)
#
#func _clear_brain() -> void:
#	if not _brain_state: return
#
#	remove_child(_brain_state)
#	_brain_state.queue_free()
#	_brain_state = null
#
#func _update_state() -> void:
#	if _next_state != "":
#		# here we reset a bunch of stuff that we want to be reset on switching a state
#		var old_state : String = _state
#		_chasing_target = false
#		set_target(null)
#		follow_navpath = false
#		_looking_around = false
#		panicking = false
#
#		set_state(_next_state)
#		_set_brain_for_current_state()
#		_set_interrupts_for_current_state()
#
#		var old_state_data = Flow.get_brain_state_data(type, old_state)
#		var state_data = Flow.get_brain_state_data(type, _state)
#		if state_data["alert"] == true:
#			if old_state_data["alert"] == false:
#				_alert_enter.play()
#				_alertness_icon.play("alert")
#				_alertness_icon.visible = true
#				# tween this beauty
#				_alertness_icon_tween.interpolate_property(_alertness_icon, "scale", Vector2.ONE * 2.0, Vector2.ONE, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
#				_alertness_icon_tween.start()
#		else:
#			_alertness_icon.play("suspicious")
#
#		alerted = state_data["alert"]
#
#	_next_state = ""
#
#func _update_move_sfx_dict() -> void:
#	if is_moving:
#		var walk_state_key = Global.WALK_MODE.WALKING if not is_running else Global.WALK_MODE.RUNNING
#		var sound_region_key = Global.SOUND_REGION.DEFAULT
#
#		if is_in_wheat:
#			sound_region_key = Global.SOUND_REGION.WHEAT
#		elif is_on_floor:
#			sound_region_key = Global.SOUND_REGION.FLOOR
#		elif is_on_floor:
#			sound_region_key = Global.SOUND_REGION.FLOOR
#
#		_sfx_movement_samples = _sfx_footsteps.get(walk_state_key).get(sound_region_key)
#
#func _update_animation_state() -> void:
#	if alive and not _is_attacking and not _is_interacting:
#		if _velocity == Vector2.ZERO:
#			_play_animation(classCharacterAnimations.ANIMATION_TYPE.IDLE)
#		else:
#			if _has_wood_in_hand:
#				_play_animation(classCharacterAnimations.ANIMATION_TYPE.WALK_CARRY_WOOD)
#			else:
#				if _movement_speed != _run_movement_speed:
#					_play_animation(classCharacterAnimations.ANIMATION_TYPE.WALK)
#				elif _movement_speed == _run_movement_speed:
#					_play_animation(classCharacterAnimations.ANIMATION_TYPE.RUN)
#
#func _set_item(v : classItem) -> void:
#	._set_item(v)
#
## call this for continuous alerting things (ex. villager looking at player)
#func _change_alertedness_by(factor : float) -> void:
#	self.alertness += factor * ALERTNESS_BASE_FACTOR * get_process_delta_time()
#
## call this for directly alerting things (ex. window breaking sound)
#func _change_alertedness_directly_by(factor : float) -> void:
#	self.alertness += factor * ALERTNESS_BASE_FACTOR
#
#func _get_alertness_distance_factor_to(object : Node2D) -> float:
#	var distance := global_position.distance_to(object.global_position)
#	var f : float
#	if distance < ALERTNESS_DISTANCE_FACTOR_MIN_DISTANCE:
#		f = 1.0
#	elif ALERTNESS_DISTANCE_FACTOR_MAX_DISTANCE <= distance:
#		f = 0.0
#	else:
#		f = 1.0 - (distance - ALERTNESS_DISTANCE_FACTOR_MIN_DISTANCE) / (ALERTNESS_DISTANCE_FACTOR_MAX_DISTANCE - ALERTNESS_DISTANCE_FACTOR_MIN_DISTANCE)
#	return lerp(ALERTNESS_DISTANCE_FACTOR_MIN, 1.0, f)
#
#func _update_sabotage_fix(delta) -> void:
#	_fix_start_time = _fix_start_time + delta
#	_sabotage_bar.value = _fix_start_time
#	if _fix_start_time >= _last_found_sabotaged.sabotage_duration:
#		_finish_fixing_sabotage()
#
#func _finish_fixing_sabotage() -> void:
#	_last_found_sabotaged.fix()
#	_last_found_sabotaged = null
#	_is_fixing_sabotage = false
#	_has_sabotage_target = false
#	_sabotage_bar.hide()
#
#func _cancel_fixing_sabotage() -> void:
#	_last_found_sabotaged.cancel_fixing()
#	_last_found_sabotaged = null
#	_is_fixing_sabotage = false
#	_has_sabotage_target = false
#	_sabotage_bar.hide()
#
#func _finish_knockback() -> void:
#	._finish_knockback()
#	if has_item() and _last_attacker and _last_attacker.is_in_group("players"):
#		set_next_state("HUNT_TARGET")

################################################################################
### SIGNAL CALLBACKS
#func _on_sabotage_detect_range_body_entered(body : Node2D) -> void:
#	if body is classInteractable and body.is_sabotageable() and body.is_sabotaged:
#		_on_interrupt_sabotage_found(body)
#
#func _on_object_seen(object : Node2D) -> void:
#	# don't see things if not alive
#	if not alive:
#		return
#
#	# alive player seen
#	if object.is_in_group("players") and object.alive and object.seeable:
#		# If player is in human form and not doing any sabotage, villagers should ignore him.
#		if object.body_state == object.BODY_STATE.HUMAN and not object.is_sabotaging:
#			return
#		_change_alertedness_by(object.visibility_factor * _get_alertness_distance_factor_to(object))
#		if alertness == 1.0:
#			open_investigation("WEREWOLF_SEEN", object, object.global_position)
#		return
#
#	# dead NPC seen
#	if object.is_in_group("npcs"):
#		if not object.alive and not object.investigated:
#			_change_alertedness_by(0.5)
#			if alertness == 1.0:
#				open_investigation("CORPSE_SEEN", object, object.global_position)
#		return
#
#func _on_bell_activated(bell : classBell) -> void:
#	if alive and not bell.investigated:
#		set_alertness(1.0)
#		open_investigation("BELL_HEARD", bell, bell.global_position)
#
#func _on_bell_deactivated(_bell : classBell) -> void:
#	pass
#
#func _on_died() -> void:
#	State.case_manager.close_all_investigations(self)
#	_vision_cone.visible = false
#	_alertness_icon.visible = false
#	set_collision_layer_bit(ConfigData.PHYSICS_LAYER.CORPSE, true)
#	_play_animation(classCharacterAnimations.ANIMATION_TYPE.DEATH)
#
#func _on_audio_source_detected(source_owner : Node2D, spawn_position : Vector2, _source_data : Dictionary) -> void:
#	if ConfigData.DEBUG_PLAYER_NOT_SEEABLE:
#		print("Audio player detection disabled")
#		return
#
#	if not alive or source_owner.investigated:
#		return
#
#	var _sound_source_type = _source_data.get("type", Global.SOUND_SOURCE_TYPE.NONE)
#
#	if _sound_source_type == Global.SOUND_SOURCE_TYPE.NONE:
#		return
#
#	if source_owner.is_in_group("players"):
#		if _sound_source_type == Global.SOUND_SOURCE_TYPE.WALKING:
#			if _current_day_phase == State.DAY_STATE.NIGHT:
#				_change_alertedness_by(ALERTNESS_PLAYER_HEARD_FACTOR)
#	else:
#		if _sound_source_type == Global.SOUND_SOURCE_TYPE.INTERACTION and _current_day_phase == State.DAY_STATE.NIGHT:
#			_change_alertedness_by(ALERTNESS_PLAYER_HEARD_FACTOR)
#		if _sound_source_type == Global.SOUND_SOURCE_TYPE.SABOTAGING:
#			_change_alertedness_by(ALERTNESS_PLAYER_HEARD_FACTOR)
#		if _sound_source_type == Global.SOUND_SOURCE_TYPE.BREAKING:
#			_change_alertedness_directly_by(1.0)
#		if _sound_source_type == Global.SOUND_SOURCE_TYPE.ATTACKED and source_owner.is_in_group("npcs"):
#			_change_alertedness_directly_by(1.0)
#			print("Player" + name + " heard attack on " + source_owner.name)
#	if alertness == 1.0:
#		open_investigation("ANY_SOUND_HEARD", source_owner, spawn_position)
##
#func _on_animation_finished() -> void:
#	if not _is_patrol_idle_animation_playing:
#		._on_animation_finished()

#func _on_day_phase_updated(day_phase : int) -> void:
#	_current_day_phase = day_phase
#	_on_interrupt_day_phase_updated()
