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
onready var _ground_collision_shape := $CollisionShape2D
onready var _interactablesArea2D := $InteractablesArea2D
onready var _buildingArea2D := $BuilidingArea2D
onready var _body_root := $BodyRoot
onready var _animator := $BodyRoot/AnimationPlayer
onready var _speed_boost_timer = $SpeedBostTimer

# EXTERNAL DATA
var _downforce = 0.0

var _walk_speed = 0.0
var _run_speed = 0.0
var _jump_speed = 0.0
var _jump_min_distance = 0.0
var _jump_max_distance = 0.0

# INTERNAL CACHED VARS
var _interacting := false
var _movement_speed = 0.0
var _dropped := false
var _falling_down := false
var _jumped := false
var _jump_start := Vector2.ZERO
var _vertical_speed = 0.0
var _upforce = 1.0

# COLLIDED INTERACTABLES
var _overlapping_bodies := []
# COLLIDED BUILDINGS
var _overlapping_buildings := []


################################################################################
## GODOT CALLBACKS
func _ready() -> void:
	add_to_group("players")
	setup_data(Flow.player_data)
	_interactablesArea2D.connect("body_entered", self, "_on_interactable_body_entered")
	_interactablesArea2D.connect("body_exited", self, "_on_interactable_body_exited")
	_buildingArea2D.connect("body_entered", self, "_on_building_ledge_entered")
	_buildingArea2D.connect("body_exited", self, "_on_building_ledge_exited")
	_animator.connect("animation_finished", self, "_on_animation_finished")
	_speed_boost_timer.connect("timeout", self, "_on_speed_booster_timer_timeout")
	controllable = true

func _physics_process(_delta : float) -> void:
	if controllable:
		_interact()
		_update_is_moving()
		_update_look_direction()
		_move()
		_update_jump_and_drop()


################################################################################
## PUBLIC FUNCTIONS
func setup_data(data : Dictionary) -> void:
	_walk_speed = data.get("walk_speed")
	_run_speed = data.get("run_speed")
	_jump_speed = data.get("jump_speed")
	_jump_min_distance = data.get("jump_min_distance")
	_jump_max_distance = data.get("jump_max_distance")
	_downforce = data.get("jump_downforce")
	_movement_speed = _walk_speed
	_vertical_speed = _jump_speed
	_speed_boost_timer.wait_time = data.get("speed_boost_duration")
	gravity_scale = _downforce
	set_collision_mask_bit(4, true)

func disable() -> void:
	controllable = false
	linear_velocity = Vector2.ZERO

func get_width() -> float:
	return _ground_collision_shape.shape.extents.x * scale.x


################################################################################
## PRIVATE FUNCTIONS
func _move() -> void:
	if _interacting:
		return
	if Input.is_action_pressed("move_left"):
		linear_velocity.x = 0
		apply_central_impulse(Vector2.LEFT * _movement_speed)
		emit_signal("direction_update", Vector2.LEFT)
	if Input.is_action_pressed("move_right"):
		linear_velocity.x = 0
		apply_central_impulse(Vector2.RIGHT * _movement_speed)
		emit_signal("direction_update", Vector2.RIGHT)

func _interact():
	if not _jumped and not _falling_down:# and not _falling_down:
		if not _interacting and Input.is_action_just_pressed("interact"):
			for body in _overlapping_bodies:
				if body is classPowerUp or body.owner is classPowerUp:
					continue
				if body.owner.interactable:
					if body is classTrafo:
						_animator.play("Idle")
					else:
						_animator.play("Bark")
					body.owner.interact(self)
					_interacting = true
					_jump_start = global_position

func _update_jump_and_drop() -> void:
	if _interacting:
		return
	if Input.is_action_pressed("move_down"):
		_update_ledge_collision()
#	if not _falling_down and
	if not _falling_down and linear_velocity.y <= 0:
		#if Input.is_action_pressed("jump"):
		if not _jumped and Input.is_action_pressed("jump"):
			_jump_start.y = global_position.y
			_vertical_speed = _jump_speed
			_jump()
	if _jumped:
		if (not Input.is_action_pressed("jump") and global_position.y < _jump_start.y - _jump_min_distance) or global_position.y < _jump_start.y - _jump_max_distance:
			_set_active_building_collision(true)
			gravity_scale = _downforce
			_falling_down = true
	if _falling_down and linear_velocity.y == 0:
		_reset_jump()
	if _falling_down:
		if  linear_velocity.y == 0:
			_reset_drop()

func _update_is_moving():
	if _interacting:
		is_moving = false
		return
	if linear_velocity.x == 0.0:
		if not _jumped and not _falling_down:
			_animator.play("Idle")
		is_moving = false
	else:
		if not _jumped and not _falling_down:
			_animator.play("Run")
		is_moving = true
		emit_signal("position_update", global_position)

func _update_ledge_collision() -> void:
	if _overlapping_buildings.size() > 0:
		_set_active_building_collision(false)
		gravity_scale = _downforce
		_falling_down = true
		_falling_down = true
		_animator.play("Jump")

func _update_look_direction() -> void:
	if not is_moving:
		return
	if linear_velocity.x < -0.1 and _body_root.scale.x > 0:
		_body_root.scale = Vector2(_body_root.scale.x * -1, _body_root.scale.y)
	elif linear_velocity.x > 0.1 and _body_root.scale.x < 0:
		_body_root.scale = Vector2(_body_root.scale.x * -1, _body_root.scale.y)

func _jump() -> void:
	_animator.play("Jump")
	gravity_scale = _upforce
	apply_central_impulse(Vector2.UP * _vertical_speed) # * delta)
	_set_active_building_collision(true)
	_jumped = true

func _reset_jump() -> void:
	_jumped = false
	_falling_down = false
	_jump_start.y = global_position.y
	gravity_scale = _downforce

func _reset_drop() -> void:
	_falling_down = false
	_falling_down = false
	_jump_start.y = global_position.y
	gravity_scale = _downforce

func _set_active_building_collision(value : bool) -> void:
	set_collision_mask_bit(4, value)

################################################################################
## SIGNAL CALLBACKS
func _on_interactable_body_entered(_body : Node2D) -> void:
	if _body is classPowerUp:
		_movement_speed = _run_speed
		_speed_boost_timer.start()
		_body.hide()
		return
	_overlapping_bodies = _interactablesArea2D.get_overlapping_bodies()

func _on_interactable_body_exited(_body : Node2D) -> void:
	if _body is classPowerUp:
		return
	if _overlapping_bodies.has(_body):
		_overlapping_bodies.erase(_body)

func _on_building_ledge_entered(_body : Node2D) -> void:
	_overlapping_buildings = _buildingArea2D.get_overlapping_bodies()
	if Input.is_action_pressed("move_down"):
		_set_active_building_collision(false)

func _on_building_ledge_exited(_body : Node2D) -> void:
	if _overlapping_buildings.has(_body):
		_overlapping_buildings.erase(_body)
	#if _overlapping_buildings.size() == 0:
		_set_active_building_collision(true)
		#_animator.play("Jump")

func _on_animation_finished(value : String) -> void:
	if value == "Bark" or value == "Idle":
		_interacting = false

func _on_speed_booster_timer_timeout() -> void:
	_movement_speed = _walk_speed
