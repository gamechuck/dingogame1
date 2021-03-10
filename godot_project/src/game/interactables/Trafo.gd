class_name classTrafo
extends classInteractable



################################################################################
## SIGNALS
signal trafo_fixed


################################################################################
## PUBLIC VARIABLES
var is_fixed := false

################################################################################
## PRIVATE VARIABLES
onready var _animator = $AnimationPlayer
onready var _fixing_particle = $FixParticles2D


################################################################################
## GODOT CALLBACKS
func _ready():
	add_to_group("trafos")
	is_fixed = false
	_animator.play("Broken")
	$AudioStreamPlayer2D.stop()
	$VisibilityNotifier2D.connect("screen_entered", self, "_on_viewport_entered")
	$VisibilityNotifier2D.connect("screen_exited", self, "_on_viewport_exited")


################################################################################
## PUBLIC FUNCTIONS
func interact(_interactor : Node2D) -> void:
	_fix()

func make_fixed() -> void:
	is_fixed = true
	interactable = false
	_animator.play("Idle")
	$AudioStreamPlayer2D.stop()


################################################################################
## PRIVATE FUNCTIONS
func _fix() -> void:
	_animator.play("Idle")
	_fixing_particle.restart()
	$AudioStreamPlayer2D.stop()
	emit_signal("trafo_fixed")


################################################################################
## SIGNAL CALLBACKS
func _on_viewport_entered() -> void:
	if is_fixed:
		return
	$AudioStreamPlayer2D.play()

func _on_viewport_exited() -> void:
	$AudioStreamPlayer2D.stop()
