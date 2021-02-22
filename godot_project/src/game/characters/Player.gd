class_name classPlayer
extends classCharacter

################################################################################
## CONSTANTS
const SCENE_BLOODY_TRACK := preload("res://src/game/BloodyTrack.tscn")
var FREEROAM_CAMERA_SPEED := 150.0
var INTERACT_PROMPT_OFFSET := Vector2(0, -40.0)
enum BODY_STATE { HUMAN, WOLF }

################################################################################
## PUBLIC VARIABLES

# override
func set_movement_speed(v : float) -> void:
	_movement_speed = v
	emit_signal("overlay_update_requested", hp, _is_attacking, is_running)

# defines how fast player can be detected by others, from 0.0 to 1.0
# gets changed depending if player is moving, running, in wheat, etc.
var visibility_factor := 0.0 setget set_visibility_factor
func set_visibility_factor(v : float) -> void:
	visibility_factor = clamp(v, 0.0, 1.0)
	if _visibility_factor_label:
		_visibility_factor_label.text = str(v)

# if true, NPCs can see the player
# (funny name but makes it more consistent with hearable, smellable, etc.)
var seeable := true

var is_sabotaging := false

var body_state : int = BODY_STATE.HUMAN

################################################################################
## PRIVATE VARIABLES
export var _human_frames : SpriteFrames
export var _werewolf_frames : SpriteFrames
# Nodes
onready var _smoke_sprite := $SmokeSprite
onready var _visibility_factor_label := $GUI/AboveHead/VisibilityFactorLabel
onready var _camera := $GameCamera
onready var _prompt : classInteractPrompt = $InteractablePrompt
onready var _exit_container_ray := $ExitContainerRay
onready var _tracks_parent := get_parent().get_parent().get_parent().get_node("Objects/BloodTracks")
onready var _sabotage_progress_bar = $SabotageGUI/ProgressBar

var _closest_interactable : Node2D = null

# keep track of last interactable that's under the mouse
var _mouse_entered_interactable : Node2D = null

var _is_hidden := false
# Attack stuff
var _last_attack_time := 0.0
var _is_dashing := false
var _dash_start_position := Vector2.ZERO

# Window jumping stuff
var _window_jumping := false
var _window_jump_up := false
var _window_position := Vector2.ZERO
var _last_position := Vector2.ZERO
# Mouse input stuff
var _mouse_too_close := false
# Blood tracks stuff
var _can_update_tracks := false
var _track_spawn_delay_counter = 0.0
var _track_counter = 0
# Player transformation stuff
var _should_transform := false
var _is_transforming := false
var _current_day_phase := 0
# Sabotage stuff
var _sabotage_start_time := 0.0
# Movement noise
var _movement_noise := 0.0
onready var _movement_noises := {
}
onready var _sfx_footsteps := {
}
onready var _sfx_attack_samples := []

################################################################################
## SIGNALS
signal blood_track_spawn_requested
signal overlay_update_requested # hp, _is_attacking, _movement_speed == ConfigData.PLAYER_RUN_SPEED

################################################################################
## GODOT CALLBACKS
func _ready() -> void:
	_setup_data()
	add_to_group("players")
	controllable = true
	_current_direction = Global.DIRECTION.E
	_last_animation_type = classCharacterAnimations.ANIMATION_TYPE.IDLE
	_default_animations = classCharacterAnimations.PLAYER_DEFAULT
	_in_wheat_animations = classCharacterAnimations.PLAYER_IN_WHEAT
	_animated_sprite.play("default")
	set_hp_max(ConfigData.PLAYER_HP_MAX)
	set_hp(hp_max)

	attack_power = ConfigData.PLAYER_ATTACK_POWER
	_knockback_start_speed = ConfigData.PLAYER_START_KNOCKBACK_SPEED

	_connect_player_signals()

	# interactable prompt
	_prompt.set_as_toplevel(true)
	_prompt.visible = false

	_exit_container_ray.set_as_toplevel(true)

	# debug
	_debug_godmode = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_PLAYER_GODMODE
	if ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_PLAYER_NOCLIP:
		set_collision_mask_bit(ConfigData.PHYSICS_LAYER.SOLID, false)
	seeable = not (ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_PLAYER_NOT_SEEABLE)
	# debug / shapes
	_collision.visible = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_VISIBLE_COLLISION_SHAPES and ConfigData.DEBUG_VISIBLE_PLAYER_COL_SHAPE
	_attack_range.visible = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_VISIBLE_COLLISION_SHAPES and ConfigData.DEBUG_VISIBLE_PLAYER_ATTACK_RANGE
	_see_range.visible = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_VISIBLE_COLLISION_SHAPES and ConfigData.DEBUG_VISIBLE_PLAYER_SEE_RANGE
	_hear_range.visible = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_VISIBLE_COLLISION_SHAPES and ConfigData.DEBUG_VISIBLE_PLAYER_HEAR_RANGE
	_use_range.visible = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_VISIBLE_COLLISION_SHAPES and ConfigData.DEBUG_VISIBLE_PLAYER_USE_RANGE

func _physics_process(delta : float) -> void:
	# update moving and running
	is_moving = _velocity != Vector2.ZERO
	if not ConfigData.is_using_mouse_input() and _get_any_directional_key_pressed():
		is_running = is_moving and Input.is_action_pressed("sprint")

	_set_closest_interactable(_get_closest_object_in_use_range())
	_update_prompt_state()
	_update_speed()
	_update_visibility_factor()

	if _can_update_animations and not _is_knocked_back:
		if body_state == BODY_STATE.WOLF:
			_run_movement_speed = ConfigData.PLAYER_RUN_SPEED
		else:
			_run_movement_speed = ConfigData.PLAYER_HUMAN_RUN_SPEED
		_update_animation_state()

	if not Flow.is_in_editor_mode:
		if alive:
			_update_move_sfx_dict()
			if _can_update_tracks:
				_update_tracks_state()
			if _is_knocked_back:
				_knock_back()
			else:
				if _is_transforming:
					_update_transformation()
				elif is_in_container:
					if ConfigData.is_using_mouse_input() or ConfigData.is_using_hybrid_input():
						look_at_position(get_global_mouse_position())
					if ConfigData.is_using_keyboard_input() or ConfigData.is_using_hybrid_input():
						_move_direction = _get_move_direction_from_input()
						_turn_towards_direction(_move_direction)
					if not _is_attacking:
						if (not ConfigData.is_using_mouse_input() and Input.is_action_just_pressed("attack_default")) or (ConfigData.is_using_mouse_input() and Input.is_action_just_pressed("attack_with_mouse")):
							_attack_from_container()
						elif Input.is_action_just_pressed("interact"):
							# exit container (interact with it)
							container.interact(self)
						else:
							# exiting container
							if ConfigData.is_using_mouse_input() or ConfigData.is_using_hybrid_input():
								if Input.is_action_just_pressed("move_with_mouse"):
									_exit_container_in_direction(Vector2.RIGHT.rotated(_movement_angle))
							if ConfigData.is_using_keyboard_input() or ConfigData.is_using_hybrid_input():
								_exit_container_in_direction(_get_move_direction_from_input(true))
				else:
					if not _is_attacking and not _is_transforming:
						if _window_jumping:
							_window_jump()
						elif _is_dashing:
							_dash(delta)
						elif is_sabotaging:
							_sabotage_update(delta)
					if not _is_interacting and controllable and not _window_jumping and not _is_dashing and not _is_attacking:
						if Input.is_action_just_pressed("interact") and _prompt.visible: # F KEY
							_interact()
						if Input.is_action_just_pressed("attack_default"): # E KEY
							if body_state == BODY_STATE.WOLF and not ConfigData.is_using_mouse_input():
								_begin_dash()
							elif _prompt.visible:
								_start_sabotage()
						if Input.is_action_just_pressed("attack_with_mouse"):
							if body_state == BODY_STATE.WOLF and not ConfigData.is_using_keyboard_input():
								_begin_dash()
						if ConfigData.is_using_keyboard_input():# keyboard controls
							_move_with_keyboard()
						elif ConfigData.is_using_mouse_input(): # mouse controls
							_move_with_mouse()
						else: # hybrid input
							_move_with_hybrid_input()
		else:
			# dead; control separate camera as spectator camera
			# (it gets detached with set_as_toplevel())
			_move_direction = _get_move_direction_from_input()
			_camera.global_position += _move_direction * _movement_speed * 2.0 * get_physics_process_delta_time()

func _input(event : InputEvent) -> void:
	if event is InputEventJoypadButton:
		print(event.button_index)

################################################################################
## PUBLIC FUNCTIONS

func get_camera() -> Camera2D:
	return _camera as Camera2D

func take_damage(amount : float, damager : Node2D) -> void:
	if _debug_godmode: return

	.take_damage(amount, damager)

	_camera.shake(_camera.SHAKE_DURATION_TAKE_DAMAGE, _camera.SHAKE_STRENGTH_TAKE_DAMAGE)

	_drop_carried_character()

	_is_attacking = false
	_is_dashing = false


################################################################################
## PRIVATE FUNCTIONS

func _setup_data() -> void:
	var _sfx_movement_data = Flow.player_data.get("assets").get("movement_sfx", {})

	for walk_mode_key in _sfx_movement_data:
		var sound_region_dict = _sfx_movement_data.get(walk_mode_key)
		var walk_mode_enum_value = Global.WALK_MODE.values()[Global.WALK_MODE.keys().find(walk_mode_key)]
		_sfx_footsteps[walk_mode_enum_value] = {}

		for sound_region_key in sound_region_dict:
			var sound_region_enum_value = Global.SOUND_REGION.values()[Global.SOUND_REGION.keys().find(sound_region_key)]
			var asset_path_array = sound_region_dict.get(sound_region_key)

			_sfx_footsteps[walk_mode_enum_value][sound_region_enum_value] = []

			for i in asset_path_array.size():
				_sfx_footsteps.get(walk_mode_enum_value).get(sound_region_enum_value).append(load(asset_path_array[i]))

	var _sfx_attack_data = Flow.npcs_data.get("assets").get("attack_sfx", [])
	for i in _sfx_attack_data.size():
		_sfx_attack_samples.append(load(_sfx_attack_data[i]))

	var _sfx_movement_noise_data = Flow.player_data.get("values").get("movement_noise", {})

	for walk_mode_key in _sfx_movement_noise_data:
		var walk_mode_dict = _sfx_movement_noise_data.get(walk_mode_key)
		var walk_mode_enum_value = Global.WALK_MODE.values()[Global.WALK_MODE.keys().find(walk_mode_key)]
		_movement_noises[walk_mode_enum_value] = {}

		for sound_region_key in walk_mode_dict:
			var sound_region_enum_value = Global.SOUND_REGION.values()[Global.SOUND_REGION.keys().find(sound_region_key)]
			_movement_noises[walk_mode_enum_value][sound_region_enum_value] = walk_mode_dict.get(sound_region_key)

func _connect_player_signals() -> void:
	connect("died", self, "_on_died")
	connect("blood_track_spawn_requested", self, "_on_blood_track_spawn_requested")

func _move_with_mouse() -> void:
	look_at_position(get_global_mouse_position())
	var distance = get_global_mouse_position().distance_to(global_position)

	if not _mouse_too_close:
		if distance < 5.0:
			_mouse_too_close = true
	elif _mouse_too_close and distance > 15.0:
		_mouse_too_close = false

	if not _mouse_too_close and Input.is_action_pressed("move_with_mouse"):
		if distance > 45.0 and not is_running:
			is_running = true
		elif distance < 35.0 and is_running:
			is_running = false

		_move_direction = get_current_look_vector()

		_move_in_direction(_move_direction)
	elif _velocity != Vector2.ZERO:
		_velocity = Vector2.ZERO

func _move_with_keyboard() -> void:
	_move_direction = _get_move_direction_from_input()
	_turn_towards_direction(_move_direction)
	_move_in_direction(_move_direction)

func _move_with_hybrid_input() -> void:
	if _get_any_directional_key_pressed():
		_move_with_keyboard()
	else:
		_move_with_mouse()

# ejects player from container towards this direction IF there's no SOLID blocking it
# returns true if successful
func _exit_container_in_direction(direction : Vector2) -> bool:
	# idea is that we cast ray from outside towards container and get point on the edge
	# then we move the player at that point, and have it collide so it gets pushed out and aligned with container col shape
	# finally we check if there are SOLIDs there. if not, we move the player there
	# col layers and masks are temporarily modified to include only the things we want (and restored later)

	if direction == Vector2.ZERO:
		return false

	var pos_collision := Vector2.INF
	var direct_space_state := get_world_2d().direct_space_state

	# remember and setup layers and masks
	_exit_container_ray.set_collision_mask_bit(0, true)
	var c = _exit_container_ray.collision_mask
	#
	var container_col_layer_old = container.collision_layer
	container.collision_layer = c
	#
	var container_col_mask_old = container.collision_mask
	container.collision_mask = c
	#
	var col_mask_old = collision_mask
	collision_mask = 0
	#
	var pos_old = global_position

	# fetch container collision and shape
	var container_collision : CollisionShape2D = container.get_node("Collision")

	# calculate the edge position on the shape
	var pos_end = container_collision.global_position
	var pos_start = pos_end + direction * 200.0
	_exit_container_ray.global_position = pos_start
	_exit_container_ray.cast_to = pos_end - pos_start
	_exit_container_ray.force_raycast_update()
	if _exit_container_ray.is_colliding():
		pos_collision = _exit_container_ray.get_collision_point()
	else:
		push_error("exit container ray not colliding with container!")

	collision_mask = c

	# move and collide player to push him out and align with container
	global_position = pos_collision
	move_and_slide(Vector2.ZERO)

	collision_mask = 0

	# setup query shape
	var shape = Physics2DShapeQueryParameters.new()
	shape.transform = transform
	shape.set_shape($Collision.shape)
	shape.collision_layer = col_mask_old

	# query
	var intersected_objects := direct_space_state.intersect_shape(shape)

	# restore col layers and masks
	container.collision_layer = container_col_layer_old
	container.collision_mask = container_col_mask_old
	collision_mask = col_mask_old

	# process query result
	if intersected_objects.size() > 0:
		global_position = pos_old
		return false
	else:
		# free to exit!
		container_enter_position = global_position
		_interact_with(container)
		return true

func _get_move_direction_from_input(just_pressed := false) -> Vector2:
	var dir := Vector2()

	if just_pressed:
		if Input.is_action_just_pressed("move_down"):
			dir.y += 1
		if Input.is_action_just_pressed("move_up"):
			dir.y -= 1
		if Input.is_action_just_pressed("move_left"):
			dir.x -= 1
		if Input.is_action_just_pressed("move_right"):
			dir.x += 1
	else:
		if Input.is_action_pressed("move_down"):
			dir.y += 1
		if Input.is_action_pressed("move_up"):
			dir.y -= 1
		if Input.is_action_pressed("move_left"):
			dir.x -= 1
		if Input.is_action_pressed("move_right"):
			dir.x += 1

	return dir.normalized()

func _get_any_directional_key_pressed() -> bool:
	if Input.is_action_pressed("move_down") or Input.is_action_pressed("move_up") or  Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		return true
	else:
		return false

func _move_in_direction(direction : Vector2) -> void:
	if not _is_knocked_back:
		_velocity = move_and_slide(direction * _movement_speed)
	else:
		_velocity = move_and_slide(direction * _current_knockback_speed)

func _window_jump() -> void:
		if _window_jump_up:
			if _animated_sprite.frame == 1:
				global_position = _window_position + Vector2(0.0, 2.0)
			elif _animated_sprite.frame > 1:
				global_position = _window_position + Vector2(0.0, -16.0)
		else:
			if _animated_sprite.frame == 1:
				global_position = _window_position + Vector2(0.0, 2.0)
			elif _animated_sprite.frame > 1:
				global_position = _window_position + Vector2(0.0, 15.0)

func _begin_dash() -> void:
	if body_state == BODY_STATE.HUMAN or carried_character:
		return
	_attack_range.rotation = _movement_angle
	_dash_start_position = global_position
	_last_position = _dash_start_position
	_is_dashing = true

func _dash(delta : float) -> void:
	if body_state == BODY_STATE.HUMAN:
		return

	_move_direction = get_current_look_vector().normalized() * ConfigData.PLAYER_ATTACK_DASH_SPEED * delta
	_move_in_direction(_move_direction)
	if global_position.distance_to(_last_position) < 1 or global_position.distance_to(_dash_start_position) > ConfigData.PLAYER_ATTACK_DASH_DISTANCE or _is_closest_interactable_attackable():
		_is_dashing = false
		_attack()
	_last_position = global_position

func _cancel_dash() -> void:
	_move_direction = Vector2.ZERO
	_is_dashing = false

func _attack_from_container() -> void:
	if body_state == BODY_STATE.HUMAN:
		return

	if ConfigData.is_using_mouse_input():
		look_at_position(get_global_mouse_position())
	else:
		_attack_range.rotation = _movement_angle

	set_as_toplevel(true)
	if container:
		container._animated_sprite.play("empty")
	_animated_sprite.show()
	_attack()

func _attack() -> void:
	if _is_attacking or body_state == BODY_STATE.HUMAN or carried_character:
		return

	_play_animation(classCharacterAnimations.ANIMATION_TYPE.ATTACK)

	_sfx_attack.stream = _sfx_attack_samples[randi() % _sfx_attack_samples.size()]
	_sfx_attack.play()
	_is_attacking = true

	emit_signal("overlay_update_requested", hp, _is_attacking, is_running)

	# deal damage to characters or break objects
	var npc_hit := false
	for target in _attack_range.get_overlapping_bodies():
		if target is classBreakable and target.breakable and not target.is_broken:
			target.shatter()
		# If we have this object_in_sight() check, it can't hit villager from container
		if target is classNPC and target.alive and object_in_sight(target):
			if container:
				# if we're in container, hide the body (drag it in)
				target.take_damage(999999, self)
				target.visible = false
				target.global_position = Vector2(999999, 999999.0)
				npc_hit = true
			else:
				# otherwise damage target, twice as much if target is not alerted (surprise attack)
				if target.alerted:
					target.take_damage(attack_power, self as Node2D)
				else:
					target.take_damage(attack_power * ConfigData.PLAYER_STEALTH_ATTACK_POWER_MODIFIER, self as Node2D)

				npc_hit = true

				if not target.alive:
					emit_signal("blood_track_spawn_requested")

	if npc_hit:
		_camera.shake(_camera.SHAKE_DURATION_DEAL_DAMAGE, _camera.SHAKE_STRENGTH_DEAL_DAMAGE)

# player's interact action; interacts with closest interactable
func _interact() -> void:
	# ignore if already interacting
	if _is_interacting:
		return

	# take care of carried character first
	if carried_character:
		# if closest interactable is empty container, dispose of body, otherwise drop it
		if _closest_interactable and _closest_interactable is classContainer and not _closest_interactable.has_item():
			carried_character = null
		else:
			_drop_carried_character()
		return

	_is_interacting = true

	# get closest object in use range and interact with it if it exists
	var interactable : Node2D = _get_closest_object_in_use_range()
	if not interactable:
		return

	_interact_with(interactable)

func _interact_with(interactable : Node2D) -> void:
	_play_animation(classCharacterAnimations.ANIMATION_TYPE.INTERACT)
	# bell or door
	if interactable is classBell or interactable is classDoor:
		interactable.interact(self)
		return

	# window
	if interactable is classWindow:
		if interactable.traversable and (interactable.is_broken or interactable.is_open):
			_can_update_animations = false
			_window_jumping = true
			_last_position = global_position
			_window_position = interactable.global_position
			if interactable.position.y < position.y:
				_window_jump_up = true
				_animated_sprite.play("window_jump_n")
			else:
				_animated_sprite.play("window_jump_s")
				_window_jump_up = false
		else:
			interactable.interact(self)
		return

	# storm shelter # haystack
	if interactable is classStormShelter or interactable is classHaystack:
		_is_hidden = not _is_hidden
		_velocity = Vector2.ZERO # we need to reset velocity, to stop movement sounds
		interactable.interact(self)
		return

	# weapon barrel
	if interactable is classWeaponBarrel:
		if not _is_hidden:
			if not interactable.has_item():
				_is_hidden = not _is_hidden
				_velocity = Vector2.ZERO # we need to reset velocity, to stop movement sounds
				interactable.interact(self)
		elif _is_hidden:
			_is_hidden = not _is_hidden
			interactable.interact(self)
		return

	# corpse
	if interactable is classCharacter:
		if interactable.alive or not interactable.visible or interactable.investigated:
			return
		if body_state == BODY_STATE.HUMAN:
			return

		interactable.visible = false
		interactable.global_position = Vector2(999999, 999999.0)
		carried_character = interactable
		return

func _start_sabotage() -> void:
	# skip if conditions are met
	if not _closest_interactable \
			or _closest_interactable is classCharacter \
			or _closest_interactable.is_sabotaged \
			or _is_transforming \
			or body_state == BODY_STATE.WOLF:
		return

	is_sabotaging = true
	_sabotage_start_time = 0.0
	_sabotage_progress_bar.max_value = _closest_interactable.sabotage_duration
	_sabotage_progress_bar.get_parent().global_position = _closest_interactable.global_position + INTERACT_PROMPT_OFFSET
	_sabotage_progress_bar.show()
	_prompt.hide()

func _sabotage_update(delta : float) -> void:
	if not is_moving and is_sabotaging and _closest_interactable:
		_sabotage_start_time = _sabotage_start_time + delta
		_sabotage_progress_bar.value = _sabotage_start_time
		_closest_interactable.update_sabotage(self)
		if _sabotage_start_time >= _closest_interactable.sabotage_duration:
			_sabotage(_closest_interactable)
			_cancel_sabotage()
	else:
		_cancel_sabotage()

func _cancel_sabotage() -> void:
	is_sabotaging = false
	_sabotage_start_time = 0.0
	_sabotage_progress_bar.hide()

func _sabotage(interactable : Node2D) -> void:
	if interactable and interactable is classInteractable and interactable.is_sabotageable():
		interactable.finish_sabotage(self)

func _set_camera_as_parent_child(value : bool) -> void:
	if value:
		var camera_position = _camera.global_position
		remove_child(_camera)
		get_parent().add_child(_camera)
		_camera.global_position = camera_position
	else:
		get_parent().remove_child(_camera)
		add_child(_camera)
		_camera.position = Vector2.ZERO

func set_hp(v : int, quiet := false) -> void: # override
	.set_hp(v, quiet)
	emit_signal("overlay_update_requested", v, _is_attacking, is_running)

func _set_closest_interactable(interactable : Node2D) -> void:
	_closest_interactable = interactable

func _is_closest_interactable_attackable() -> bool:
	if _closest_interactable == null:
		return false
	if _closest_interactable is classWindow and not _closest_interactable.is_broken:
		return true
	return false

func _update_tracks_state() -> void:
	if is_moving:
		_track_spawn_delay_counter = _track_spawn_delay_counter + 1
	if _track_spawn_delay_counter > ConfigData.PLAYER_TRACKS_SPAWN_DELAY:
		var track = SCENE_BLOODY_TRACK.instance()
		track.global_position = global_position
		_tracks_parent.add_child(track)
		track.set_direction(get_current_look_direction())
		_track_counter = _track_counter - 1
		_track_spawn_delay_counter = 0;
		if _track_counter <= 0:
			_track_spawn_delay_counter = 0
			_can_update_tracks = false

func _update_prompt_state() -> void:
	# always hide all prompts, then we'll show them as needed
	_prompt.hide_all()
	_prompt.hide()

	# ignore showing any prompt if these conditions are met
	if not alive or _is_transforming or is_sabotaging:
		return

	# show EXIT prompt if we're in container
	if is_in_container:
		_prompt.global_position = container.global_position + INTERACT_PROMPT_OFFSET
		_prompt.set_interact_text(_prompt.INTERACT_TEXT_TYPE.EXIT)
		_prompt.show_interact()
		_prompt.show()
		return

	# show DROP prompt above us if we're carrying a character
	if carried_character:
		# if closest interactable is empty container, show DISPOSE, otherwise show DROP
		if _closest_interactable and _closest_interactable is classContainer and not _closest_interactable.has_item():
			_prompt.global_position = _closest_interactable.global_position + INTERACT_PROMPT_OFFSET
			_prompt.set_interact_text(_prompt.INTERACT_TEXT_TYPE.DISPOSE)
		else:
			_prompt.global_position = global_position + INTERACT_PROMPT_OFFSET
			_prompt.set_interact_text(_prompt.INTERACT_TEXT_TYPE.DROP)
		_prompt.show_interact()
		_prompt.show()
		return

	# ignore showing interactable prompt if closest interactable doesn't exist
	if not _closest_interactable:
		return
	# ignore showing interactable prompt if closest interactable is being fixed by NPC
	if _closest_interactable is classInteractable and _closest_interactable.is_being_fixed:
		return

	# don't show prompt for window that's not traversable or is locked
	if _closest_interactable is classWindow:
		if _closest_interactable.is_open and not _closest_interactable.traversable:
			return

	# don't show prompt for weapon barrel that contains something AND is sabotaged
	if _closest_interactable is classWeaponBarrel:
		if (_closest_interactable.has_item() or _closest_interactable.has_character()) and _closest_interactable.is_sabotaged:
			return

	# don't show prompt for locked or broken door
	if _closest_interactable is classDoor:
		if _closest_interactable.is_broken or _closest_interactable.is_locked:
			return

	# reposition and show the prompt container
	_prompt.global_position = _closest_interactable.global_position + INTERACT_PROMPT_OFFSET
	_prompt.show()

	match body_state:
		BODY_STATE.HUMAN:
			# skip corpses
			if _closest_interactable is classCharacter:
				return
			# show interact
			if _closest_interactable.is_interactable():
				_prompt.set_interact_text(_prompt.INTERACT_TEXT_TYPE.INTERACT)
				_prompt.show_interact()
			# show sabotage
			if _closest_interactable.is_sabotageable() and not _closest_interactable.is_sabotaged:
				_prompt.show_sabotage()

		BODY_STATE.WOLF:
			# show CARRY corpse
			if _closest_interactable is classCharacter:
				if not _closest_interactable.investigated:
					_prompt.set_interact_text(_prompt.INTERACT_TEXT_TYPE.CARRY)
					_prompt.show_interact()
				return
			# show interact
			if _closest_interactable.is_interactable():
				_prompt.set_interact_text(_prompt.INTERACT_TEXT_TYPE.INTERACT)
				_prompt.show_interact()

func _update_speed() -> void:
	# use godspeed if enabled
	if ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_PLAYER_GODSPEED:
		set_movement_speed(ConfigData.PLAYER_GODMODE_SPEED)
		return

	# in_wheat speed
	if is_in_wheat:
		set_movement_speed(ConfigData.PLAYER_WHEAT_MOVE_SPEED)
		return

	# carry character speed
	if carried_character:
		set_movement_speed(ConfigData.PLAYER_CARRY_CORPSE_SPEED)
		return

	# pick speed depending on body state and running state
	if is_running:
		match body_state:
			BODY_STATE.HUMAN:
				set_movement_speed(ConfigData.PLAYER_HUMAN_RUN_SPEED)
			BODY_STATE.WOLF:
				set_movement_speed(ConfigData.PLAYER_RUN_SPEED)
	else:
		match body_state:
			BODY_STATE.HUMAN:
				set_movement_speed(ConfigData.PLAYER_HUMAN_WALK_SPEED)
			BODY_STATE.WOLF:
				set_movement_speed(ConfigData.PLAYER_WALK_SPEED)

func _update_visibility_factor() -> void:
	if is_in_container:
		self.visibility_factor = 0.0
	else:
		self.visibility_factor = ConfigData.PLAYER_VISIBILITY_FACTOR_INITIAL
		if is_moving:
			self.visibility_factor += ConfigData.PLAYER_VISIBILITY_FACTOR_MOD_MOVING
			if is_running:
				self.visibility_factor += ConfigData.PLAYER_VISIBILITY_FACTOR_MOD_RUNNING
		if is_in_wheat:
			self.visibility_factor += ConfigData.PLAYER_VISIBILITY_FACTOR_MOD_IN_WHEAT

func _start_transformation() -> void:
	_cancel_sabotage()
	_cancel_dash()
	_is_attacking = false
	_should_transform = false
	_is_transforming = true
	_velocity = Vector2.ZERO
	_prompt.hide()
	_smoke_sprite.show()
	_smoke_sprite.frame = 0
	_smoke_sprite.play("transform_smoke")

func _update_transformation() -> void:
	if _smoke_sprite.frame >= 1:
		if _current_day_phase == State.DAY_STATE.DUSK or  _current_day_phase == State.DAY_STATE.NIGHT:
			body_state = BODY_STATE.WOLF
			_default_animations = classCharacterAnimations.PLAYER_DEFAULT
			_in_wheat_animations = classCharacterAnimations.PLAYER_IN_WHEAT
			_animated_sprite.frames = _werewolf_frames
			_run_movement_speed = ConfigData.PLAYER_RUN_SPEED
		elif _current_day_phase == State.DAY_STATE.DAWN or  _current_day_phase == State.DAY_STATE.DAY:
			body_state = BODY_STATE.HUMAN
			_drop_carried_character()
			_default_animations = classCharacterAnimations.VILLAGER_DEFAULT
			_in_wheat_animations = classCharacterAnimations.VILLAGER_IN_WHEAT
			_animated_sprite.frames = _human_frames
			_run_movement_speed = ConfigData.PLAYER_HUMAN_RUN_SPEED
		_on_animation_finished()
		_is_transforming = false

func _update_move_sfx_dict() -> void:
	if is_moving:
		var walk_state_key = Global.WALK_MODE.WALKING if not is_running else Global.WALK_MODE.RUNNING
		var sound_region_key = Global.SOUND_REGION.DEFAULT

		if is_in_wheat:
			sound_region_key = Global.SOUND_REGION.WHEAT
		elif is_on_floor:
			sound_region_key = Global.SOUND_REGION.FLOOR
		elif is_on_floor:
			sound_region_key = Global.SOUND_REGION.FLOOR

		_movement_noise = _movement_noises.get(walk_state_key, _movement_noise).get(sound_region_key, _movement_noise)
		_sfx_movement_samples =  _sfx_footsteps.get(walk_state_key).get(sound_region_key)

func _update_animation_state() -> void:
	if alive and not _is_attacking and not _is_interacting:
		if _velocity == Vector2.ZERO:
			if carried_character:
				_play_animation(classCharacterAnimations.ANIMATION_TYPE.IDLE_WITH_BODY)
			else:
				_play_animation(classCharacterAnimations.ANIMATION_TYPE.IDLE)
		else:
			if carried_character:
				_play_animation(classCharacterAnimations.ANIMATION_TYPE.WALK_WITH_BODY)
			else:
				if _movement_speed != _run_movement_speed:
					_play_animation(classCharacterAnimations.ANIMATION_TYPE.WALK)
				elif _movement_speed == _run_movement_speed:
					_play_animation(classCharacterAnimations.ANIMATION_TYPE.RUN)

func _play_move_sound() -> bool:
	if ._play_move_sound():
		if body_state == BODY_STATE.WOLF:
			emit_signal("audio_source_spawn_requested", self, global_position, { "noise": _movement_noise, "type" : Global.SOUND_SOURCE_TYPE.WALKING })
		return true
	else:
		return false

func _drop_carried_character():
	if not carried_character:
		return
	_can_update_animations = false
	carried_character.global_position = global_position
	carried_character.visible = true
	carried_character.is_in_wheat = is_in_wheat
	carried_character._update_animation_dict()
	carried_character._play_animation(classCharacterAnimations.ANIMATION_TYPE.DEATH)
	carried_character = null
	_play_animation(classCharacterAnimations.ANIMATION_TYPE.DROP_BODY)

################################################################################
## SIGNAL CALLBACKS

func _on_animation_finished() -> void:
	if _is_attacking:
		_is_attacking = false
		if is_in_container:
			set_as_toplevel(false)
			_animated_sprite.hide()
			if container and container.has_character():
				container._animated_sprite.play("contains_character")
		emit_signal("overlay_update_requested", hp, _is_attacking, is_running)
	if _is_interacting:
		_is_interacting = false
	if _window_jumping:
		_window_jumping = false
		if _should_transform:
			_start_transformation()
	if not _is_knocked_back:
		_can_update_animations = true

func _on_died() -> void:
	_camera.set_as_toplevel(true)
	_camera.global_position = global_position
	_is_interacting = false
	_window_jumping = false
	_can_update_animations = false
	_play_animation(classCharacterAnimations.ANIMATION_TYPE.DEATH)

func _on_blood_track_spawn_requested() -> void:
	if _track_counter < ConfigData.PLAYER_TRACKS_CAP - ConfigData.PLAYER_TRACKS_ON_KILL:
		_track_counter = _track_counter + ConfigData.PLAYER_TRACKS_ON_KILL
	_can_update_tracks = true

func _on_mouse_detector_mouse_entered(mouse_detector : Area2D) -> void:
	var mouse_detector_owner : Node2D = mouse_detector.get_parent()
	_mouse_entered_interactable = mouse_detector_owner

func _on_mouse_detector_mouse_exited() -> void:
	_mouse_entered_interactable = null

func _on_day_phase_updated(day_phase : int) -> void:
	if day_phase == State.DAY_STATE.DAY or day_phase == State.DAY_STATE.NIGHT:
		return
	if _is_transforming:
		return

	_current_day_phase = day_phase
	_should_transform = true
	if not _window_jumping:
		_start_transformation()
