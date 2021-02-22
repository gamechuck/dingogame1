class_name classDoor
extends classBreakable

################################################################################
## PUBLIC VARIABLES
var can_be_closed := true
var is_open : bool = false

func get_sprite_offset() -> Vector2:
	return $AnimatedSprite.offset

################################################################################
## PRIVATE VARIABLES
onready var _opener_detector := $OpenerDetector
onready var _sfx_open := $SFX/Open
onready var _sfx_close := $SFX/Close
onready var _door_body :=  $AnimatedSprite.get_parent()



################################################################################
## GODOT CALLBACKS

func _ready():
	add_to_group("doors")
	close(true)
	_opener_detector.connect("body_entered", self, "_on_opener_detector_body_entered")
	_opener_detector.connect("body_exited", self, "_on_opener_detector_body_exited")
	State.connect("day_phase_updated", self, "_on_day_phase_updated")

################################################################################
## PUBLIC FUNCTIONS
# Called by player
func interact(interactor : Node2D) -> void:
	toggle()
	.interact(interactor)

func sabotage(_interactor : Node2D) -> void:
	is_locked = false
	.sabotage(_interactor)

func toggle() -> void:
	if is_locked or is_broken:
		return
	if is_open and _opener_detector.get_overlapping_bodies().size() < 1:
		close()
	else:
		open()

func open(override := false) -> void:
	if (not override and is_locked) or is_open:
		return
	is_open = true
	_door_body.set_collision_layer_bit(ConfigData.PHYSICS_LAYER.SOLID, false)
	_door_body.set_collision_layer_bit(ConfigData.PHYSICS_LAYER.SIGHT_OCCLUSION, false)
	_sfx_open.play()
	update_sprite()

func close(quiet := false) -> void:
	if not can_be_closed or is_broken:
		return
	_door_body.set_collision_layer_bit(ConfigData.PHYSICS_LAYER.SOLID, true)
	_door_body.set_collision_layer_bit(ConfigData.PHYSICS_LAYER.SIGHT_OCCLUSION, true)
	is_open = false
	update_sprite()
	if not quiet:
		_sfx_close.play()

func shatter() -> void:
	is_broken = true
	is_locked = false
	can_be_closed = false
	open()
	emit_signal("audio_source_spawn_requested", self, global_position, { "noise": break_noise_range, "type" : Global.SOUND_SOURCE_TYPE.BREAKING })

func update_sprite() -> void:
	if is_broken:
		animated_sprite.play("broken")
	elif can_be_closed and not is_open:
		animated_sprite.play("closed")
	elif is_open:
		animated_sprite.play("open")
	else:
		animated_sprite.play("open")

################################################################################
## SIGNAL CALLBACKS
func _on_opener_detector_body_entered(body : Node2D) -> void:
	# skip if body is dead
	# (otherwise player can put enemy corpse next to door and open it :D)
	if not body.alive:
		return

	open(true)

func _on_opener_detector_body_exited(body : Node2D) -> void:
	# skip if body is dead
	if not body.alive:
		return

	# the body doesn't get removed from the array, so empty array is of size 1
	if _opener_detector.get_overlapping_bodies().size() <= 1:
		close()

func _on_day_phase_updated(day_phase : int) -> void:
	if day_phase == State.DAY_STATE.DAY:
		is_locked = false
	else:
		close()
		if not is_sabotaged and not is_broken:
			is_locked = true
