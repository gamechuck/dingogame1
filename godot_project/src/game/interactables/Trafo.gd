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
## PRIVATE VARIABLES
onready var _animator = $AnimationPlayer
onready var _fixing_particle = $FixParticles2D

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
	_fix()


################################################################################
## PRIVATE FUNCTIONS
func _set_data() -> void:
	pass

func _fix() -> void:
	is_being_fixed = true
	interactable = false
	_animator.play("Idle")
	_fixing_particle.restart()
	emit_signal("trafo_fixed")


