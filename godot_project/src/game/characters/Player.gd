class_name classPlayer
extends classCharacter

################################################################################
## SIGNALS
signal position_update
signal direction_update


################################################################################
## PRIVATE VARIABLES
onready var _jump_timer := $Timer
# MOVEMENT STUFF
var _walk_speed = 55
var _run_speed = 155
var _jump_speed = 300
var _jumped := false
var _jump_start := Vector2.ZERO

################################################################################
## GODOT CALLBACKS
func _ready() -> void:
	add_to_group("players")
	_setup_data()

	controllable = true

	_animated_sprite.play("default")
	_jump_timer.connect("timeout", self, "_on_jump_timeout")

func _physics_process(_delta : float) -> void:
	if controllable:
		_update_is_moving()
		_update_movement_speed()
		if linear_velocity.x != 0.0:
			emit_signal("position_update", global_position)
		_move()


################################################################################
## PRIVATE FUNCTIONS
func _setup_data() -> void:
	_movement_speed = _walk_speed

func _move() -> void:
	if Input.is_action_pressed("move_left"):
		linear_velocity.x = 0
		apply_central_impulse(Vector2.LEFT * _movement_speed)
		emit_signal("direction_update", Vector2.LEFT)
	elif Input.is_action_pressed("move_right"):
		linear_velocity.x = 0
		apply_central_impulse(Vector2.RIGHT * _movement_speed)
		emit_signal("direction_update", Vector2.RIGHT)
	if not _jumped:
		if Input.is_action_just_pressed("move_up"):
			linear_velocity.y = 0
			apply_central_impulse(Vector2.UP * _jump_speed)
			_jump_start = global_position
			_jumped = true
	elif _jumped:
		if global_position.y < _jump_start.y - 11:
			gravity_scale = 7
		if  linear_velocity.y == 0:
			_jumped = false
			gravity_scale = 1

func _update_movement_speed():
	if Input.is_action_just_pressed("sprint"):
		_movement_speed = _run_speed
	if Input.is_action_just_released("sprint"):
		_movement_speed = _walk_speed

func _update_is_moving():
	if linear_velocity.x == 0.0:
		is_moving = false
	else:
		is_moving = true

func _on_jump_timeout() -> void:
	gravity_scale = 7
