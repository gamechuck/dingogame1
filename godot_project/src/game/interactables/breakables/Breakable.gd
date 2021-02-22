class_name classBreakable
extends classInteractable

#************** PUBLIC VARS **********************
export var breakable := true
export var traversable := true
export var is_broken := false
export var break_noise_range := 500.0

onready var animated_sprite := $AnimatedSprite

func get_sprite_offset() -> Vector2:
	return $AnimatedSprite.offset

var sprite_frames : SpriteFrames = null setget set_sprite_frames
func set_sprite_frames(v : SpriteFrames):
	sprite_frames = v
	animated_sprite.frames = v

#************** PRIVATE VARS **********************#
export (Array) var _sfx_break_array
onready var _sfx := $SFX

#************** GODOT CALLBACKS **********************#
func _ready():
	add_to_group("breakables")

	# disabled since sprite frames are set after adding to the tree
#	_update_sprite()

#************** PUBLIC METHODS **********************#
func update_sprite() -> void:
	if breakable and is_broken:
		animated_sprite.play("broken")
	else:
		animated_sprite.play("default")

func play_stream(stream : AudioStream) -> void:
	if not stream:
		return

	_sfx.stream = stream
	_sfx.play()

# break() is reserved in Godot!
func shatter():
	is_broken = true
	is_locked = false
	play_stream(_sfx_break_array[randi() % _sfx_break_array.size()])
	update_sprite()
	emit_signal("audio_source_spawn_requested", self, self.global_position,  { "noise": break_noise_range, "type" : Global.SOUND_SOURCE_TYPE.BREAKING })
