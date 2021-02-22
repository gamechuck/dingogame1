class_name classBell
extends classInteractable

################################################################################
## SIGNALS
signal activated
signal deactivated


################################################################################
## PUBLIC VARIABLES
func get_sprite_offset() -> Vector2:
	return $AnimatedSprite.offset


################################################################################
## PRIVATE VARIABLES
onready var _sprite := $AnimatedSprite
onready var _bell_sfx := $BellSFX

var _active := false setget set_active, get_active
func set_active(value : bool) -> void:
	if _active == value:
		 return
	if value and is_sabotaged:
		return

	_active = value

	if _active:
		_sprite.play("active")
		_bell_sfx.play()
		emit_signal("activated", self)
	else:
		_sprite.play("idle")
		_bell_sfx.stop()
		emit_signal("deactivated", self)


################################################################################
## GODOT CALLBACKS
func _ready() -> void:
	add_to_group("bells")


################################################################################
## PUBLIC FUNCTIONS
func interact(interactor : Node2D) -> void:
	.interact(interactor)
	toggle_active()

func sabotage(_interactor : Node2D) -> void:
	.sabotage(_interactor)
	set_active(false)

func get_active() -> bool:
	return _active

func toggle_active() -> void:
	set_active(not _active)
