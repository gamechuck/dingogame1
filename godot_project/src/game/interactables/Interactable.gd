class_name classInteractable
extends Node2D


################################################################################
## PUBLIC VARIABLES
export var spawn_offset := Vector2.ZERO
export var interactable := true
func is_interactable() -> bool:
	return interactable
export var interact_noise_range := 5.0

export var sabotage_duration := 3.0
export var sabotageable := false
func is_sabotageable() -> bool:
	return sabotageable
export var sabotage_noise_range := 30.0

var sprite_offset : Vector2 setget , get_sprite_offset
func get_sprite_offset() -> Vector2:
	if _animated_sprite:
		return _animated_sprite.offset
	else:
		return Vector2.ZERO

var pending_repairs := false
var is_being_fixed := false
var is_sabotaged := false
var is_locked := false setget , get_is_locked
func get_is_locked() -> bool:
	return is_locked
var investigated := false

################################################################################
## PRIVATE VARIABLES
var _sabotage_sound_spawn_time := 0.0
onready var _animated_sprite := $AnimatedSprite

################################################################################
## SIGNALS
signal audio_source_spawn_requested #Node2D owner, Vector2 spawn_position, float radius

################################################################################
## GODOT CALLBACKS

func _ready() -> void:
	add_to_group("interactables")

################################################################################
## PUBLIC FUNCTIONS

func interact(_interactor : Node2D) -> void:
	emit_signal("audio_source_spawn_requested", self, self.global_position, { "noise": interact_noise_range, "type" : Global.SOUND_SOURCE_TYPE.INTERACTION })

func update_sabotage(_interactor : Node2D) -> void:
	if OS.get_ticks_msec() > _sabotage_sound_spawn_time + 250.0:
		_sabotage_sound_spawn_time = OS.get_ticks_msec()
		emit_signal("audio_source_spawn_requested", self, self.global_position, { "noise": sabotage_noise_range, "type" : Global.SOUND_SOURCE_TYPE.SABOTAGING })

func finish_sabotage(_interactor : Node2D) -> void:
	is_sabotaged = true
	emit_signal("audio_source_spawn_requested", self, self.global_position, { "noise": sabotage_noise_range, "type" : Global.SOUND_SOURCE_TYPE.SABOTAGING })

func start_fixing(_interactor : Node2D) -> void:
	is_being_fixed = true

func fix() -> void:
	is_sabotaged = false
	pending_repairs = false
	is_being_fixed = false

func schedule_fixing() -> void:
	pending_repairs = true

func cancel_fixing() -> void:
	pending_repairs = false
	is_being_fixed = false
