class_name classCharacter, "res://assets/textures/class_icons/classCharacter.png"
extends KinematicBody2D

################################################################################
## CONSTANTS

#const COLOR_NAVPATH := Color(1, 0, 0)
#var NAVPATH_UPDATE_INTERVAL := 0.2 # [s]
var MOVEMENT_TURN_SPEED := 540.0 # [degrees/s]
var LOOK_SPEED := 540.0 # [degrees/s]
#var HUNT_TARGET_NOT_FOCUSED_DEBOUNCE := 1.5 # [s]

################################################################################
## PUBLIC VARIABLES

var controllable := false
#var is_in_wheat := false
#var is_in_container := false
#var is_on_carpet := false
#var is_on_floor := false

# only used by player for now
var is_moving := false
var is_running := false

var alive := true

# allows the base class to know if it's hunting target atm or not
##var hunting_target := false
##
### if true, character sprite will slightly shake
### (implemented for NPC only)
##var panicking := false setget set_panicking
##func set_panicking(v : bool) -> void:
##	panicking = v
##
##var nav_path : PoolVector2Array = []
##
##var npc_group_id := ""
##var waypoint_group_ids := []
##
##var last_target_waypoint : classWaypoint
#
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

#	_hp_bar.value = hp

# max health points; hp will not go above this value
var hp_max := 3 setget set_hp_max
func set_hp_max(v : int) -> void:
	hp_max = v

#	_hp_bar.max_value = hp_max

# how much damage you deal when attacking
var attack_power := 1
#
## if true, can't be investigated again by NPCs
## (set this to true when ex. NPCs are done investigating this corpse)
#var investigated := false setget set_investigated
#func set_investigated(v : bool) -> void:
#	investigated = v
#
## keeps track of entered container
#var container : classContainer = null
#
## keep track where we entered the container from so on exiting it we end up here
#var container_enter_position := Vector2()
#
## keep track of carried character (for corpse manipulation by player)
#var carried_character : KinematicBody2D = null
#
## called by AI
#var follow_navpath := false setget set_follow_navpath
#func set_follow_navpath(v : bool) -> void:
#	follow_navpath = v

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
#onready var _shadow := $Shadow
#onready var _see_range := $SeeRange
#onready var _hear_range := $HearRange
#onready var _foot_range := $FootRange
#onready var _gui := $GUI
#onready var _hp_bar := $GUI/AboveHead/HPBar
#onready var _name_label := $GUI/AboveHead/NameLabel
#onready var _navpath_update_delay := $NavpathUpdateDelay


var _is_attacking := false
var _is_interacting := false

var _movement_speed := 10.0 setget set_movement_speed
func set_movement_speed(v : float) -> void:
	_movement_speed = v
var _run_movement_speed := 0.0
var _movement_angle := 0.0
var _velocity := Vector2.ZERO
var _target : Node2D = null
var _look_angle := 0.0 setget set_look_angle
func set_look_angle(v : float) -> void:
	_look_angle = v
#	_see_range.rotation = _look_angle

var _last_attacker : Node2D
var _current_direction : int = Global.DIRECTION.E
var _move_direction : Vector2 = Vector2.ZERO

var _debug_godmode := false
var _can_update_animations := true
var _sfx_move_start_time = 0.0
var _sfx_movement_samples := []
var _sfx_damaged_samples := []

#var _target_focused := false
#var _target_not_focused_duration := 0.0
# debug
#var _debug_draw_nav_path := false
#
#var _item : classItem = null
#var _chasing_target := false
#var _look_at_target := false
#var _looking_around := false
#var _looking_around_phase_offset : float
#
## Knockback stuff
#var _is_knocked_back := false
#var _knockback_start_speed := 0.0
#var _current_knockback_speed := 0.0
#var _last_animation_type : int = classCharacterAnimations.ANIMATION_TYPE.NONE
#var _last_animation_dict : Dictionary = {}
#var _default_animations := {}
#var _in_wheat_animations := {}
#
#var _using_navpath := false
#

################################################################################
## SIGNALS

signal died
#signal closest_object_requested
#signal nav_path_to_target_requested
#signal nav_path_to_position_requested
#signal object_seen # object
#signal target_not_seen
#signal random_waypoint_requested
#signal audio_source_spawn_requested #Node2D owner, Vector2 spawn_position, float radius

################################################################################
## GODOT CALLBACKS
func _ready() -> void:
	add_to_group("characters")

#	_navpath_update_delay.one_shot = true
	_animated_sprite.play("default")
	set_hp_max(hp_max)
	set_hp(hp_max, true)
#	_name_label.text = name
#	_looking_around_phase_offset = rand_range(0.0, TAU)

	_connect_signals()

func _physics_process(_delta : float) -> void:
	if alive:
		_play_move_sound()
#

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
#
#func start_looking_around() -> void:
#	_looking_around = true
#
#func stop_looking_around() -> void:
#	_looking_around = false
###
#func turn_to_waypoint_direction(waypoint : classWaypoint) -> void:
#	_movement_angle = deg2rad(waypoint.direction)
#	set_look_angle(deg2rad(waypoint.direction))

#func set_random_waypoint_as_target() -> void:
#	emit_signal("random_waypoint_requested")
#	if _target:
#		last_target_waypoint = _target
#		_target.reserved = true
#
#func set_closest_object_as_target(target_group : String) -> void:
#	emit_signal("closest_object_requested", target_group)
#
#func set_closest_non_empty_as_target(group : String) -> void:
#	var objects := []
#	for o in get_tree().get_nodes_in_group(group):
#		if o.is_empty(): continue
#		objects.append(o)
#
#	if objects.size() > 0:
#		set_target(Flow.get_closest_object(self, objects))
#
#func set_closest_non_full_as_target(group : String) -> void:
#	var objects := []
#	for o in get_tree().get_nodes_in_group(group):
#		if o.is_full(): continue
#		objects.append(o)
#
#	if objects.size() > 0:
#		set_target(Flow.get_closest_object(self, objects))
#
#func set_random_object_as_target(target_group := "") -> void:
#	if target_group != "":
#		var objects := get_tree().get_nodes_in_group(target_group)
#		if objects.size() > 0:
#			set_target(objects[randi() % objects.size()])
#
#func set_object_as_target(object : Node2D) -> void:
#	set_target(object)
#
#func request_nav_path_to_target(ignore_waypoints : bool) -> void:
#	nav_path = []
#	emit_signal("nav_path_to_target_requested", _target, ignore_waypoints)
#
#func request_nav_path_to_position(pos : Vector2, ignore_waypoints : bool) -> void:
#	nav_path = []
#	emit_signal("nav_path_to_position_requested", pos, ignore_waypoints)
#
#func chase_target() -> void:
#	_chasing_target = true
#
#func take_item_from(c : Node2D) -> void:
#	if not c: return
#	if not c.is_in_group("weapon_barrels"): return
#	if not c.has_item(): return
#
#	_set_item(c.pop_item())
#
#func put_item_into(c : Node2D) -> void:
#	if not c: return
#	if not c.is_in_group("weapon_barrels"): return
#	if c.is_full(): return
#
#	c.push_item(_item)
#	_set_item(null)

#func turn_to_target_waypoint_direction() -> void:
#	if _target is classWaypoint and _target.directional:
#		turn_to_waypoint_direction(_target)

# AI / CHECKS
#
#func has_target() -> bool:
#	return _target != null
#
#func has_item() -> bool:
#	return _item != null
#
#func object_has_item(object : Node2D) -> bool:
#	return object.has_item()
#
#func has_nav_path() -> bool:
#	return nav_path.size() > 0
#
#func object_full(object : Node2D) -> bool:
#	return object.is_full()
#
#func object_visible(object : Node2D) -> bool:
#	return object_in_sight(object) and object_in_see_range(object) and object.visible
#
#func object_in_range(object : Node2D, r : float) -> bool:
#	return global_position.distance_to(object.global_position) <= r
#
#func object_in_use_range(object : Node2D) -> bool:
#	for o in _use_range.get_overlapping_bodies():
#		if object == o:
#			return true
#	for o in _use_range.get_overlapping_areas():
#		if object == o:
#			return true
#	return false
#
#func object_in_attack_range(object : Node2D) -> bool:
#	for o in _attack_range.get_overlapping_bodies():
#		if object == o:
#			return true
#	for o in _attack_range.get_overlapping_areas():
#		if object == o:
#			return true
#	return false
#
#func object_in_see_range(object : Node2D) -> bool:
#	for o in _see_range.get_overlapping_bodies():
#		if object == o:
#			return true
#	for o in _see_range.get_overlapping_areas():
#		if object == o:
#			return true
#	return false
#
#func object_in_hear_range(object : Node2D) -> bool:
#	for o in _hear_range.get_overlapping_bodies():
#		if object == o:
#			return true
#	for o in _hear_range.get_overlapping_areas():
#		if object == o:
#			return true
#	return false
#
#func object_attackable(object : Node2D) -> bool:
#	var in_range =  object_in_attack_range(object)
#	return in_range and not _is_attacking and _can_update_animations
#
#func object_dead(object : Node2D) -> bool:
#	return not object.alive
#
#func object_has_any_item(object : Node2D) -> bool:
#	if not object: return false
#	if not object.is_in_group("item_containers"): return false
#	return object.has_item()
#
#func exists_non_empty(group : String) -> bool:
#	for o in get_tree().get_nodes_in_group(group):
#		if o.has_item():
#			return true
#	return false
#
#func exists_non_full(group : String) -> bool:
#	for o in get_tree().get_nodes_in_group(group):
#		if not o.is_full():
#			return true
#	return false
#
#func is_bell_active() -> bool:
#	for bell in get_tree().get_nodes_in_group("bells"):
#		if bell.get_active():
#			return true
#	return false
#
## returns if we're this close to end of nav_path
#func nav_path_end_in_range(r : float) -> bool:
#	if nav_path.size() == 0:
#		push_warning("nav_path is empty!")
#		return true
#
#	return global_position.distance_to(nav_path[-1]) <= r

################################################################################
## PRIVATE FUNCTIONS

func _connect_signals() -> void:
	pass
	#_use_range.connect("body_exited", self, "_on_use_range_body_exited")
#	_foot_range.connect("area_entered", self, "_on_foot_range_entered")
#	_foot_range.connect("area_exited", self, "_on_foot_range_exited")
#	_animated_sprite.connect("animation_finished", self, "_on_animation_finished")
#	$WheatRange.connect("body_entered", self, "_on_foot_body_entered")
#	$WheatRange.connect("body_exited", self, "_on_foot_body_exited")

# warning-ignore:unused_argument
func _play_animation(animation_type) -> void:
	pass
#	if _last_animation_dict == null or _last_animation_dict.size() < 1:
#		return
#	var state_settings : Dictionary = {}
#	state_settings = _last_animation_dict.get(_current_direction, {})
#	state_settings = state_settings.get(animation_type, {})
#	if state_settings == null or state_settings.size() < 1:
#		return
#	var animation_name = state_settings.get("animation_name", "default")
#	if animation_name != _animated_sprite.animation:
#		_animated_sprite.frame = 0
#
#	_animated_sprite.play(animation_name)
#	_animated_sprite.flip_h = state_settings.get("flip_h", false)

#func _update_animation_dict() -> void:
#	if not is_in_wheat and not is_in_container and _last_animation_dict != _default_animations:
#		_last_animation_dict = _default_animations
#	elif (is_in_container or is_in_wheat) and _last_animation_dict != _in_wheat_animations:
#		_last_animation_dict = _in_wheat_animations

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
#	if not _is_knocked_back:
#	else:
#	_velocity = move_and_slide(direction * _current_knockback_speed)

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
#
#	_is_knocked_back = false
#	_can_update_animations = true

#func _update_shadow() -> void:
#	if _shadow:
#		if not is_in_wheat and not _shadow.visible :
#			_shadow.visible = true
#		elif _shadow.visible:
#			_shadow.visible = false
#
#func _draw_nav_path() -> void:
#	if nav_path.size() == 0: return
#
#	draw_line(Vector2(0, 0), to_local(nav_path[0]), COLOR_NAVPATH, 4.0)
#	for i in nav_path.size() - 1:
#		draw_line(to_local(nav_path[i]), to_local(nav_path[i + 1]), COLOR_NAVPATH, 4.0)
#
#func _draw_vision_cone() -> void:
#	var points : Array = $SeeRange/CollisionShape2D.polygon
#	for i in points.size():
#		points[i] = points[i].rotated(_look_angle)
#	draw_colored_polygon(points, Color(0.1, 0.3, 0.7, 0.2))
#
#func _update_path_to(object : Node2D, ignore_waypoints : bool) -> void:
#	emit_signal("nav_path_to_target_requested", object, ignore_waypoints)
#
#func _update_path_to_position(pos : Vector2) -> void:
#	emit_signal("nav_path_to_target_position_requested", pos)

##
#func _move_on_nav_path(delta : float) -> void:
#	if nav_path.size() == 0: return
#
#	_using_navpath = true
#
#	var distance_to_next_point : float = global_position.distance_to(nav_path[0])
#	var direction_to_next_point : Vector2 = (nav_path[0] - global_position).normalized()
#
#	if distance_to_next_point < _movement_speed * delta:
#		nav_path.remove(0)
#		if nav_path.empty():
#			follow_navpath = false
#		_turn_towards_direction(direction_to_next_point)
#		_move_in_direction(direction_to_next_point)
#	else:
#		_using_navpath = true
#		_turn_towards_direction(direction_to_next_point)
#		_move_in_direction(direction_to_next_point)

#func _knock_back() -> void:
#	_can_update_animations = false
#	_current_knockback_speed -= ConfigData.PLAYER_KNOCKBACK_DECREASE_RATE
#	_turn_towards_direction(-_move_direction)
#	_move_in_direction(_move_direction)
#	_play_animation(classCharacterAnimations.ANIMATION_TYPE.KNOCKED)
#	if _current_knockback_speed <= 0.0:
#		_finish_knockback()
#
#func _finish_knockback() -> void:
#func _get_weapon_barrel_in_range(empty := false) -> Node2D:
#	var closest_container : Node2D = null
#	var distance_to_closest_container := INF
#	for object in _use_range.get_overlapping_bodies():
#		if not object.is_in_group("weapon_barrels"): continue
#		if empty and object.is_full(): continue
#		if not empty and not object.has_item(): continue
#
#		var distance_to_object = global_position.distance_to(object.global_position)
#		if distance_to_object >= distance_to_closest_container: continue
#
#		closest_container = object
#		distance_to_closest_container = distance_to_object
#
#	return closest_container
#
#func _set_item(v : classItem) -> void:
#	_item = v
#
################################################################################
### SIGNAL CALLBACKS
#func _on_foot_body_entered(body : Node) -> void:
#	if not is_in_wheat and body is classWheatField:
#		is_in_wheat = true
#		$WheatParticles.emitting = true
#
#func _on_foot_body_exited(body : Node) -> void:
#	if is_in_wheat and body is classWheatField:
#		is_in_wheat = false
#		$WheatParticles.emitting = true
#
#func _on_foot_range_entered(area : Area2D) -> void:
#	if area is classFloor:
#		is_on_floor = true
#		is_on_carpet = false
#	elif area is classCarpet:
#		is_on_floor = false
#		is_on_carpet = true
#
#func _on_foot_range_exited(area : Area2D) -> void:
#	if area is classFloor:
#		is_on_floor = false
#	elif area is classCarpet:
#		is_on_carpet = false

func _on_animation_finished() -> void:
	if _is_attacking:
		_is_attacking = false
	if _is_interacting:
		_is_interacting = false
	_can_update_animations = true

#func _on_audio_source_detected(_source_owner : Node2D, _spawn_position : Vector2, _source_data : Dictionary) -> void:
#	pass
