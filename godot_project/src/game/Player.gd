class_name classPlayer
extends RigidBody2D


################################################################################
## SIGNALS
signal position_update
signal direction_update


################################################################################
## PUBLIC VARIABLES
var controllable = true
var is_moving = false


################################################################################
## PRIVATE VARIABLES
onready var _animated_sprite := $AnimatedSprite
onready var _area2D := $Area2D
# MOVEMENT STUFF
var _movement_speed = 0
var _walk_speed = 33
var _run_speed = 99
var _jump_speed = 300
var _jumped := false
var _jump_start := Vector2.ZERO

var _overlapping_bodies := []

################################################################################
## GODOT CALLBACKS
func _ready() -> void:
	add_to_group("players")
	_setup_data()
	_area2D.connect("body_entered", self, "_on_body_entered")
	_area2D.connect("body_exited", self, "_on_body_exited")

	controllable = true
	_animated_sprite.play("default")

func _physics_process(_delta : float) -> void:
	if controllable:
		_update_is_moving()
		_update_movement_speed()
		_move()
		if Input.is_action_just_pressed("interact"):
			_interact()


################################################################################
## PUBLIC FUNCTIONS
func disable() -> void:
	controllable = false
	linear_velocity = Vector2.ZERO


################################################################################
## PRIVATE FUNCTIONS
func _setup_data() -> void:
	_movement_speed = _walk_speed

func _move() -> void:
	if Input.is_action_pressed("move_left"):
		linear_velocity.x = 0
		apply_central_impulse(Vector2.LEFT * _movement_speed)
		emit_signal("direction_update", Vector2.LEFT)
	if Input.is_action_pressed("move_right"):
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
		emit_signal("position_update", global_position)

func _interact():
	for body in _overlapping_bodies:
		if body.owner.interactable:
			body.owner.interact(self)


################################################################################
## SIGNAL CALLBACKS
func _on_body_entered(_body : Node2D) -> void:
	_overlapping_bodies = _area2D.get_overlapping_bodies()

func _on_body_exited(_body : Node2D) -> void:
	if _overlapping_bodies.has(_body):
		_overlapping_bodies.erase(_body)
