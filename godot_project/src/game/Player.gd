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
onready var _interactablesArea2D := $InteractablesArea2D
onready var _buildingArea2D := $BuilidingArea2D

# EXTERNAL DATA
var _walk_speed = 0.0
var _run_speed = 0.0
var _jump_min_speed = 0.0
var _jump_max_speed = 0.0
var _jump_wind_up_speed = 0.0
var _downforce = 0.0
var _max_jump_distance = 0.0

# INTERNAL CACHED VARS
var _movement_speed = 0.0
var _dropped := false
var _upforce = 1.0
var _vertical_speed = 0.0
var _jumped := false
var _jump_start := Vector2.ZERO

# COLLIDED INTERACTABLES
var _overlapping_bodies := []
# COLLIDED BUILDINGS
var _overlapping_buildings := []


################################################################################
## GODOT CALLBACKS
func _ready() -> void:
	add_to_group("players")
	setup_data(Flow.player_data)
	_interactablesArea2D.connect("body_entered", self, "_on_body_entered")
	_interactablesArea2D.connect("body_exited", self, "_on_body_exited")
	_buildingArea2D.connect("body_entered", self, "_on_building_entered")
	_buildingArea2D.connect("body_exited", self, "_on_building_exited")
	_animated_sprite.play("default")

	controllable = true

func _physics_process(_delta : float) -> void:
	if controllable:
		_update_is_moving()
		_update_movement_speed()
		_move()
		_update_jump_and_drop(_delta)
		_interact()


################################################################################
## PUBLIC FUNCTIONS
func setup_data(data : Dictionary) -> void:
	_walk_speed = data.get("walk_speed")
	_run_speed = data.get("run_speed")
	_jump_min_speed = data.get("jump_min_speed")
	_jump_max_speed = data.get("jump_max_speed")
	_jump_wind_up_speed = data.get("jump_wind_up_speed") * 10.0 # Just so that we don't have too huge number in json
	_downforce = data.get("jump_downforce")
	_max_jump_distance = data.get("max_jump_distance")
	_movement_speed = _walk_speed
	_vertical_speed = _jump_min_speed
	gravity_scale = _downforce
	set_collision_mask_bit(4, true)

func disable() -> void:
	controllable = false
	linear_velocity = Vector2.ZERO

func get_width() -> float:
	return _animated_sprite.get_frame().get_width() * scale.x


################################################################################
## PRIVATE FUNCTIONS
func _move() -> void:
	if Input.is_action_pressed("move_left"):
		linear_velocity.x = 0
		apply_central_impulse(Vector2.LEFT * _movement_speed)
		emit_signal("direction_update", Vector2.LEFT)
	if Input.is_action_pressed("move_right"):
		linear_velocity.x = 0
		apply_central_impulse(Vector2.RIGHT * _movement_speed)
		emit_signal("direction_update", Vector2.RIGHT)

func _interact():
	if Input.is_action_just_pressed("interact"):
		for body in _overlapping_bodies:
			if body.owner.interactable:
				body.owner.interact(self)

func _update_jump_and_drop(delta : float) -> void:
	if Input.is_action_pressed("move_down"):
		_update_ledge_collision()
	if not _jumped and not _dropped and linear_velocity.y == 0:
		if Input.is_action_pressed("move_up"):
			_vertical_speed += (_jump_wind_up_speed * delta)
			_jump()
	elif _jumped:
		if Input.is_action_just_released("move_up") or global_position.y < _jump_start.y - _max_jump_distance:
			gravity_scale = _downforce
			_vertical_speed = 0
			_set_active_building_collision(true)
		if linear_velocity.y == 0:
			_reset_jump()
	elif _dropped:
		if  linear_velocity.y == 0:
			_reset_drop()

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

func _update_ledge_collision() -> void:
		if _overlapping_buildings.size() > 0:
			_set_active_building_collision(false)
			#gravity_scale = _downforce
			_dropped = true

func _jump() -> void:
	_vertical_speed = _jump_max_speed
	_jump_start = global_position
	gravity_scale = _upforce
	apply_central_impulse(Vector2.UP * _vertical_speed)
	_set_active_building_collision(true)
	_jumped = true

func _reset_jump() -> void:
	_jumped = false
	_vertical_speed = _jump_min_speed
	gravity_scale = _downforce

func _reset_drop() -> void:
	_dropped = false
	gravity_scale = _downforce


################################################################################
## SIGNAL CALLBACKS
func _on_body_entered(_body : Node2D) -> void:
	_overlapping_bodies = _interactablesArea2D.get_overlapping_bodies()

func _on_body_exited(_body : Node2D) -> void:
	if _overlapping_bodies.has(_body):
		_overlapping_bodies.erase(_body)

func _on_building_entered(_body : Node2D) -> void:
	_overlapping_buildings = _buildingArea2D.get_overlapping_bodies()
	if Input.is_action_pressed("move_down"):
		set_deferred("_set_active_building_collision", false)

func _on_building_exited(_body : Node2D) -> void:
	if _overlapping_buildings.has(_body):
		_overlapping_buildings.erase(_body)
		_set_active_building_collision(true)

func _set_active_building_collision(value : bool) -> void:
		set_collision_mask_bit(4, value)
