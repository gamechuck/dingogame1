class_name classPlayer
extends classCharacter

################################################################################
## SIGNALS
signal position_update


################################################################################
## PRIVATE VARIABLES
onready var _movement_noises := {}
onready var _sfx_footsteps := {}
onready var _sfx_attack_samples := []

# MOVEMENT STUFF
var _walk_speed = 150.0
var _run_speed = 250.0
var _jump_speed : float = 250.0
var _jumped : bool = false
var _gravity : Vector2 = Vector2.DOWN*98


################################################################################
## GODOT CALLBACKS
func _ready() -> void:
	_animated_sprite.play("default")

	controllable = true

	_setup_data()
	add_to_group("players")

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
## PRIVATE FUNCTIONS
func _setup_data() -> void:
	_movement_speed = _walk_speed

func _attack() -> void:
	if _is_attacking: # or body_state == BODY_STATE.HUMAN or carried_character:
		return

	_play_animation(classCharacterAnimations.ANIMATION_TYPE.ATTACK)

#	_sfx_attack.stream = _sfx_attack_samples[randi() % _sfx_attack_samples.size()]
#	_sfx_attack.play()
	_is_attacking = true

	for target in _attack_range.get_overlapping_bodies():
		if target.alive and object_in_sight(target):
			target.take_damage(attack_power, self as Node2D)
		else:
			target.take_damage(attack_power * ConfigData.PLAYER_STEALTH_ATTACK_POWER_MODIFIER, self as Node2D)

func _interact() -> void:
	# ignore if already interacting
	if _is_interacting:
		return
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

func _move(delta : float) -> void:
	_velocity += (_gravity * delta)

	if _jumped:
		if _velocity.y > -_jump_speed * 0.9:
			_velocity.y += (_gravity.y * 3.0 * delta)
		if is_on_floor() and _velocity.y > 0:
			_jumped = false

	if (_velocity.y > _gravity.y * 2.0):
		_velocity.y = _gravity.y * 2.0

	move_and_slide(_velocity, Vector2.UP)
	emit_signal("position_update", global_position)

func _get_input():
	if Input.is_action_just_pressed("move_up") and not _jumped and is_on_floor():
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
		$AnimatedSprite.flip_h = true
	if Input.is_action_pressed("move_right"):
		_velocity += Vector2.RIGHT
		$AnimatedSprite.flip_h = false


	_velocity = _velocity.normalized() * _movement_speed
	_velocity.y = velocity_y

