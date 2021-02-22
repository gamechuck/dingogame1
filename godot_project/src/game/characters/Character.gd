class_name classCharacter, "res://assets/textures/class_icons/classCharacter.png"
extends KinematicBody2D

################################################################################
## CONSTANTS
var MOVEMENT_TURN_SPEED := 540.0 # [degrees/s]
var LOOK_SPEED := 540.0 # [degrees/s]

################################################################################
## PUBLIC VARIABLES

var controllable := false
# only used by player for now
var is_moving := false
var is_running := false

var alive := true

# health points
var hp := 1 setget set_hp
func set_hp(v : int, _quiet := false) -> void:
	# make sure hp stays within boundaries
	# warning-ignore:narrowing_conversion
	v = clamp(v, 0, hp_max)

	# play "taking damage" sfx if not quiet and new hp is smaller than or equal to current
#	if not quiet and v <= hp:
#		if _sfx_damaged_samples.size() > 0:
#			_sfx_take_damage.stream = _sfx_damaged_samples[randi() % _sfx_damaged_samples.size()]
#			_sfx_take_damage.play()

	# die if new hp is smaller than current and equal to 0
	if v == 0 and v < hp:
		die()

	hp = v

# max health points; hp will not go above this value
var hp_max := 3 setget set_hp_max
func set_hp_max(v : int) -> void:
	hp_max = v

var attack_power := 1

################################################################################
## PRIVATE VARIABLES
export var _on_damaged_noise := 50.0

onready var _animated_sprite := $AnimatedSprite
onready var _use_range := $UseRange
onready var _attack_range := $AttackRange
onready var _line_of_sight_ray := $LineOfSightRay
onready var _sfx_attack := $SFX/Attack
onready var _sfx_death := $SFX/Death
onready var _sfx_take_damage := $SFX/TakeDamage
onready var _sfx_movement := $SFX/Movement
onready var _damage_take_tween := $DamageTakeTween
onready var _collision := $CollisionShape2D

var _is_attacking := false
var _is_interacting := false

var _movement_speed := 10.0 setget set_movement_speed
func set_movement_speed(v : float) -> void:
	_movement_speed = v
var _movement_angle := 0.0
var _velocity := Vector2.ZERO
var _target : Node2D = null
var _look_angle := 0.0 setget set_look_angle
func set_look_angle(v : float) -> void:
	_look_angle = v

var _last_attacker : Node2D
var _current_direction : int = Global.DIRECTION.E
var _move_direction : Vector2 = Vector2.ZERO

var _debug_godmode := false
var _can_update_animations := true
var _sfx_move_start_time = 0.0
var _sfx_movement_samples := []
var _sfx_damaged_samples := []

################################################################################
## SIGNALS
signal died

################################################################################
## GODOT CALLBACKS
func _ready() -> void:
	add_to_group("characters")
	set_hp_max(hp_max)
	set_hp(hp_max, true)
	_connect_signals()
	_animated_sprite.play("default")

func _physics_process(_delta : float) -> void:
	if alive:
		_play_move_sound()


################################################################################
## PUBLIC FUNCTIONS
#
func set_target(new_target : Node2D) -> void:
	# cleanup previous target first, ex. waypoints reserved bool
	if _target:
#		if _target is classWaypoint:
#			_target.reserved = false

		_target = null

	_target = new_target

func get_target() -> Node2D:
	return _target

func die() -> void:
#	_gui.visible = false
	alive = false
	emit_signal("died")

func get_objects_in_see_range() -> Array:
	var objects := []
#	for o in _see_range.get_overlapping_bodies():
#		objects.append(o)
#	for o in _see_range.get_overlapping_areas():
#		objects.append(o)
	return objects

func get_current_look_direction() -> int:
	return _current_direction

func get_current_look_vector() -> Vector2:
	return Vector2(cos(_movement_angle), sin(_movement_angle))

func object_in_sight(object : Node2D) -> bool:
	if not object.visible:
		return false

	var ray : RayCast2D = _line_of_sight_ray

	ray.cast_to = object.global_position - global_position

	ray.clear_exceptions()
	ray.add_exception(self)
#	if is_in_container:
#		ray.add_exception(container)
	while true:
		ray.force_raycast_update()
		if not ray.is_colliding():
			return false

		var collider : Node2D = ray.get_collider()
		# found it!
		if collider.name == object.name:
			return true
		# ignore characters
		elif collider.is_in_group("characters"):
			ray.add_exception(collider)
			continue
		return false
	return false
#
func turn_to_target() -> void:
	var angle := global_position.angle_to(_target.global_position)
	_movement_angle = angle
	set_look_angle(angle)

func look_at_object(object : Node2D) -> void:
	look_at_position(object.global_position)

func look_at_position(target_position : Vector2) -> void:
	var angle = global_position.angle_to_point(target_position) + deg2rad(180.0)
	_attack_range.rotation = angle
	_movement_angle = angle
	set_look_angle(angle)

func attack(object : Node2D) -> void:
	if _is_attacking:
		return
	_is_attacking = true
	if object.is_in_group("characters"):
		object.take_damage(attack_power, self as Node2D)
#	_sfx_attack.play()
	_can_update_animations = false
	_play_animation(classCharacterAnimations.ANIMATION_TYPE.ATTACK)

func take_damage(amount : float, _damager : Node2D) -> void:
	if _debug_godmode: return
	set_hp(hp - int(amount))

	_damage_take_tween.interpolate_property(self, "modulate", Color.white * 10.0, Color.white, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_damage_take_tween.start()
	_move_direction =  (global_position - _damager.global_position).normalized()
#	_is_knocked_back = true
#	_current_knockback_speed = _knockback_start_speed
	_last_attacker = _damager

	if alive:
		emit_signal("audio_source_spawn_requested", self, global_position,  { "noise": _on_damaged_noise, "type" : Global.SOUND_SOURCE_TYPE.ATTACKED })

func activate_object(o : Node2D) -> void:
	o.set_active(true)

################################################################################
## PRIVATE FUNCTIONS

func _connect_signals() -> void:
	pass

# warning-ignore:unused_argument
func _play_animation(animation_type) -> void:
	pass

func _play_move_sound() -> bool:
	var _sfx_move_delay = ConfigData.FOOTSTEPS_SOUND_UPDATE_RATIO * (1.0 / _movement_speed)
	if is_moving and OS.get_ticks_msec() > _sfx_move_start_time + _sfx_move_delay:
		if _sfx_movement_samples.size() > 0:
			_sfx_movement.stream = _sfx_movement_samples[randi() % _sfx_movement_samples.size()]
			_sfx_movement.pitch_scale = rand_range(0.99, 1.1)
			_sfx_movement.play()
		_sfx_move_start_time = OS.get_ticks_msec()
		return true
	elif not is_moving:
		_sfx_movement.stop()
		return false
	else:
		return false

func _move_towards_target_directly(_delta : float) -> void:
	var direction := global_position.direction_to(_target.global_position).normalized()
	var movement := direction * _movement_speed
	var _linear_velocity = move_and_slide(movement)

func _turn_towards_direction(dir : Vector2) -> void:
	if dir == Vector2.ZERO: return

	var target_angle := dir.angle()
	var turn_distance : float = deg2rad(MOVEMENT_TURN_SPEED) * get_physics_process_delta_time()
	_movement_angle = _move_angle_towards_angle(_movement_angle, target_angle, turn_distance)

func _move_in_direction(direction : Vector2) -> void:
	_velocity = move_and_slide(direction * _movement_speed)

func _look_towards_angle(angle : float) -> void:
	set_look_angle(_move_angle_towards_angle(_look_angle, angle, deg2rad(LOOK_SPEED) * get_physics_process_delta_time()))

func _move_angle_towards_angle(a : float, b : float, d : float) -> float:
	# wrap things up first
	a = wrapf(a, 0, TAU)
	b = wrapf(b, 0, TAU)

	var angle_diff = Flow.get_angle_difference(a, b)
	if abs(angle_diff) <= d:
		return b
	else:
		return wrapf(a + d * sign(angle_diff), 0, TAU)

func _get_closest_object_in_use_range() -> Node2D:
	var objects := []
	objects += _use_range.get_overlapping_bodies()
	objects += _use_range.get_overlapping_areas()

	if objects.size() == 0:
		return null

	return Flow.get_closest_object(self, objects)

func _on_animation_finished() -> void:
	if _is_attacking:
		_is_attacking = false
	if _is_interacting:
		_is_interacting = false
	_can_update_animations = true
