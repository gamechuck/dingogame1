class_name classPlayer
extends classCharacter

################################################################################
## CONSTANTS
var FREEROAM_CAMERA_SPEED := 150.0
#var INTERACT_PROMPT_OFFSET := Vector2(0, -40.0)
#enum BODY_STATE { HUMAN, WOLF }

################################################################################
## PUBLIC VARIABLES

onready var _camera := $GameCamera
# Mouse input stuff
var _mouse_too_close := false
# Movement noise
var _movement_noise := 0.0
onready var _movement_noises := {
}
onready var _sfx_footsteps := {
}
onready var _sfx_attack_samples := []



const _walk_speed = 50.0
const _run_speed = 100.0
var _jump_speed : float = 60.0

var _jumped : bool = false

var _gravity : Vector2 = Vector2.DOWN*98


################################################################################
## GODOT CALLBACKS
func _ready() -> void:
	_setup_data()
	add_to_group("players")
	controllable = true
	_current_direction = Global.DIRECTION.E
#	_last_animation_type = classCharacterAnimations.ANIMATION_TYPE.IDLE
#	_default_animations = classCharacterAnimations.PLAYER_DEFAULT
	_animated_sprite.play("default")
	set_hp_max(ConfigData.PLAYER_HP_MAX)
	set_hp(hp_max)
	_connect_player_signals()
	attack_power = ConfigData.PLAYER_ATTACK_POWER
	# debug
	_debug_godmode = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_PLAYER_GODMODE
	if ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_PLAYER_NOCLIP:
		set_collision_mask_bit(ConfigData.PHYSICS_LAYER.SOLID, false)

func _physics_process(delta : float) -> void:
	if _can_update_animations:
		_update_animation_state()

	get_input()
	_velocity += (_gravity * delta)
	if _jumped and _velocity.y > 0 and is_on_floor():
		_jumped = false
	move_and_slide(_velocity, Vector2.UP)

func get_input():
	if Input.is_action_just_pressed("move_up") and not _jumped:
		_velocity.y = -_jump_speed
		_jumped = true
	var velocity_y = _velocity.y
	_velocity = Vector2.ZERO
	if Input.is_action_just_pressed("sprint"):
		_movement_speed = _run_speed
	if Input.is_action_just_released("sprint"):
		_movement_speed = _walk_speed
	if Input.is_action_pressed("move_left"):
		_velocity += Vector2.LEFT
	if Input.is_action_pressed("move_right"):
		_velocity += Vector2.RIGHT


	_velocity = _velocity.normalized() * _movement_speed
	_velocity.y = velocity_y

#	if alive:#
#		if not _is_interacting and controllable and not _is_attacking:
#			is_moving = _velocity != Vector2.ZERO
#			if _get_any_directional_key_pressed():
#				is_running = is_moving and Input.is_action_pressed("sprint")
#
#			_update_speed()
#			_move_with_keyboard()
#
#			if Input.is_action_just_pressed("interact"): # and _prompt.visible: # F KEY
#				_interact()
#			if Input.is_action_just_pressed("attack_default"): # E KEY
#				pass
#			if Input.is_action_just_pressed("attack_with_mouse"):
#				pass
#
################################################################################
## PUBLIC FUNCTIONS

func get_camera() -> Camera2D:
	return _camera as Camera2D

func take_damage(amount : float, damager : Node2D) -> void:
	if _debug_godmode: return

	.take_damage(amount, damager)

	_camera.shake(_camera.SHAKE_DURATION_TAKE_DAMAGE, _camera.SHAKE_STRENGTH_TAKE_DAMAGE)

#	_drop_carried_character()

	_is_attacking = false

################################################################################
## PRIVATE FUNCTIONS

func _setup_data() -> void:
	pass

func _connect_player_signals() -> void:
	connect("died", self, "_on_died")

func _move_with_keyboard() -> void:
	_move_direction = _get_move_direction_from_input()
	_turn_towards_direction(_move_direction)
	_move_in_direction(_move_direction)

func _get_move_direction_from_input() -> Vector2:
	var dir := Vector2()
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

func _attack() -> void:
	if _is_attacking: # or body_state == BODY_STATE.HUMAN or carried_character:
		return

	_play_animation(classCharacterAnimations.ANIMATION_TYPE.ATTACK)

#	_sfx_attack.stream = _sfx_attack_samples[randi() % _sfx_attack_samples.size()]
#	_sfx_attack.play()
	_is_attacking = true

#	emit_signal("overlay_update_requested", hp, _is_attacking, is_running)

	# deal damage to characters or break objects
	var npc_hit := false
	for target in _attack_range.get_overlapping_bodies():
#		if target is classBreakable and target.breakable and not target.is_broken:
#			target.shatter()
		# If we have this object_in_sight() check, it can't hit villager from container
		if target.alive and object_in_sight(target):
#			if container:
#				# if we're in container, hide the body (drag it in)
#				target.take_damage(999999, self)
#				target.visible = false
#				target.global_position = Vector2(999999, 999999.0)
#				npc_hit = true
#			else:
				# otherwise damage target, twice as much if target is not alerted (surprise attack)
			if target.alerted:
				target.take_damage(attack_power, self as Node2D)
			else:
				target.take_damage(attack_power * ConfigData.PLAYER_STEALTH_ATTACK_POWER_MODIFIER, self as Node2D)

			npc_hit = true


	if npc_hit:
		_camera.shake(_camera.SHAKE_DURATION_DEAL_DAMAGE, _camera.SHAKE_STRENGTH_DEAL_DAMAGE)

# player's interact action; interacts with closest interactable
func _interact() -> void:
	# ignore if already interacting
	if _is_interacting:
		return

	# take care of carried character first
#	if carried_character:
#		# if closest interactable is empty container, dispose of body, otherwise drop it
#		if _closest_interactable and _closest_interactable is classContainer and not _closest_interactable.has_item():
#			carried_character = null
#		else:
#			_drop_carried_character()
#		return

	_is_interacting = true

	# get closest object in use range and interact with it if it exists
	var interactable : Node2D = _get_closest_object_in_use_range()
	if not interactable:
		return

	_interact_with(interactable)

func _interact_with(interactable : Node2D) -> void:
	_play_animation(classCharacterAnimations.ANIMATION_TYPE.INTERACT)
	interactable.interact(self)

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

func _update_speed() -> void:
	# use godspeed if enabled
	if ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_PLAYER_GODSPEED:
		set_movement_speed(ConfigData.PLAYER_GODMODE_SPEED)
		return

	if is_running:
		set_movement_speed(ConfigData.PLAYER_HUMAN_RUN_SPEED)
	else:
		set_movement_speed(ConfigData.PLAYER_HUMAN_WALK_SPEED)

func _update_move_sfx_dict() -> void:
	if is_moving:
		var walk_state_key = Global.WALK_MODE.WALKING if not is_running else Global.WALK_MODE.RUNNING
		var sound_region_key = Global.SOUND_REGION.DEFAULT
#
#		if is_in_wheat:
#			sound_region_key = Global.SOUND_REGION.WHEAT
#		elif is_on_floor:
#			sound_region_key = Global.SOUND_REGION.FLOOR
#		elif is_on_floor:
#			sound_region_key = Global.SOUND_REGION.FLOOR

		_movement_noise = _movement_noises.get(walk_state_key, _movement_noise).get(sound_region_key, _movement_noise)
		_sfx_movement_samples =  _sfx_footsteps.get(walk_state_key).get(sound_region_key)

func _update_animation_state() -> void:
	if alive and not _is_attacking and not _is_interacting:
		if _velocity == Vector2.ZERO:
			_play_animation(classCharacterAnimations.ANIMATION_TYPE.IDLE)
		else:
			if _movement_speed != _walk_speed:
				_play_animation(classCharacterAnimations.ANIMATION_TYPE.WALK)
			elif _movement_speed == _run_speed:
				_play_animation(classCharacterAnimations.ANIMATION_TYPE.RUN)


################################################################################
## SIGNAL CALLBACKS
func _on_animation_finished() -> void:
	if _is_attacking:
		_is_attacking = false
#		if is_in_container:
#			set_as_toplevel(false)
#			_animated_sprite.hide()
#			if container and container.has_character():
#				container._animated_sprite.play("contains_character")
#		emit_signal("overlay_update_requested", hp, _is_attacking, is_running)
	if _is_interacting:
		_is_interacting = false
#	if _window_jumping:
#		_window_jumping = false
#		if _should_transform:
#			_start_transformation()
#	if not _is_knocked_back:
	_can_update_animations = true

func _on_died() -> void:
	_camera.set_as_toplevel(true)
	_camera.global_position = global_position
	_is_interacting = false
	_can_update_animations = false
	_play_animation(classCharacterAnimations.ANIMATION_TYPE.DEATH)
