class_name classTrafo
extends classInteractable


################################################################################
## PUBLIC VARIABLES
var is_being_fixed := false
var is_fixed := false


################################################################################
## SIGNALS
signal trafo_fixed


################################################################################
## GODOT CALLBACKS
func _ready():
	add_to_group("trafos")
	_animated_sprite.play("broken")
	is_being_fixed = false
	is_fixed = false


################################################################################
## PUBLIC FUNCTIONS
func interact(_interactor : Node2D) -> void:
	_fix(_interactor)


################################################################################
## PRIVATE FUNCTIONS
func _set_data() -> void:
	pass

func _fix(_interactor : classPlayer) -> void:
	is_being_fixed = true
	interactable = false
	_animated_sprite.play("default")
	emit_signal("trafo_fixed")


