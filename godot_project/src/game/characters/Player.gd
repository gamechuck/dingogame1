class_name classPlayer
extends classCharacter

################################################################################
## PRIVATE VARIABLES
onready var _camera := $GameCamera
onready var _movement_noises := {}
onready var _sfx_footsteps := {}
onready var _sfx_attack_samples := []

var _walk_speed = 50.0
var _run_speed = 100.0
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
	if alive:
		if controllable:
			_get_input()
			_move(delta)
			if not _is_interacting and  not _is_attacking:
				if Input.is_action_just_pressed("interact"):
					_interact()
				if Input.is_action_just_pressed("attack_default"): # E KEY
					pass

################################################################################
## PUBLIC FUNCTIONS
func get_camera() -> Camera2D:
	return _camera as Camera2D

################################################################################
## PRIVATE FUNCTIONS
func _setup_data() -> void:
	pass

func _connect_player_signals() -> void:
	connect("died", self, "_on_died")

func _move(delta : float) -> void:
	move_and_slide(_velocity, Vector2.UP)
	_velocity += (_gravity * delta)
	if _jumped and _velocity.y > 0 and is_on_floor():
		_jumped = false

func _get_input():
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
