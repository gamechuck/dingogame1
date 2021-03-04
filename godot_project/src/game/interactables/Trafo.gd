class_name classTrafo
extends classInteractable



################################################################################
## SIGNALS
signal trafo_fixed


################################################################################
## PUBLIC VARIABLES
var is_being_fixed := false
var is_fixed := false

################################################################################
## PUBLIC VARIABLES
onready var _animator = $AnimationPlayer

################################################################################
## GODOT CALLBACKS
func _ready():
	add_to_group("trafos")
	_animator.play("Broken")
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
	_animator.play("Idle")
	emit_signal("trafo_fixed")


