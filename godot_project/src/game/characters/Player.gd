class_name classPlayer
extends classCharacter

################################################################################
## SIGNALS
signal position_update


################################################################################
## PRIVATE VARIABLES
onready var _jump_timer := $Timer
# MOVEMENT STUFF
var _walk_speed = 55
var _run_speed = 77
var _jump_speed = 222.0
var _jumped : bool = false


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
	elif Input.is_action_pressed("move_right"):
		linear_velocity.x = 0
		apply_central_impulse(Vector2.RIGHT * _movement_speed)
	if not _jumped:
		if Input.is_action_just_pressed("move_up"):
			linear_velocity.y = 0
			apply_central_impulse(Vector2.UP * _jump_speed)
			_jump_timer.start()
			_jumped = true
			print("Jumped")
	elif _jumped and linear_velocity.y == 0:
		_jumped = false
		gravity_scale = 1
		print("Jump reset")

func _update_movement_speed():
	if Input.is_action_just_pressed("sprint"):
		_movement_speed = _run_speed
	if Input.is_action_just_released("sprint"):
		_movement_speed = _walk_speed

func _on_jump_timeout() -> void:
	gravity_scale = 7
