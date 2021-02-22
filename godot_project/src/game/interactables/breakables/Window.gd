class_name classWindow
extends classBreakable


################################################################################
## PUBLIC VARIABLES
var can_be_closed := true
var is_open : bool = false

################################################################################
## PRIVATE VARIABLES
onready var _window_knocking_sfx := preload("res://assets/audio/sfx/game/knocking_on_window.wav")

################################################################################
## GODOT CALLBACKS
func _ready():
	add_to_group("windows")
	State.connect("day_phase_updated", self, "_on_day_phase_updated")

################################################################################
## PUBLIC FUNCTIONS
# Called by player
func interact(interactor : Node2D) -> void:
	_toggle()
	.interact(interactor)

func finish_sabotage(_interactor : Node2D) -> void:
	.finish_sabotage(_interactor)
	update_sprite()

func shatter() -> void:
	can_be_closed = false
	is_open = true
	.shatter()

func open() -> void:
	is_open = true
	if not is_broken:
		animated_sprite.play("open")

func close() -> void:
	if not can_be_closed or is_broken:
		return
	is_open = false
	animated_sprite.play("closed")

func update_sprite() -> void:
	if sabotageable and is_sabotaged:
		animated_sprite.play("sabotaged")
	elif breakable and is_broken:
		animated_sprite.play("broken")
	else:
		if is_open:
			animated_sprite.play("open")
		else:
			animated_sprite.play("closed")

################################################################################
## PRIVATE FUNCTIONS

func _toggle() -> void:
	if is_locked and not is_sabotaged:
		play_stream(_window_knocking_sfx)
		return
	if is_open:
		close()
	else:
		open()


################################################################################
## SIGNAL CALLBACKS
func _on_day_phase_updated(day_phase : int) -> void:
	if day_phase == State.DAY_STATE.DAY:
		is_locked = false
	else:
		close()
		if not is_sabotaged and not is_broken:
			is_locked = true
