class_name classThief
extends classInteractable

################################################################################
## SIGNALS CALLBACKS
signal thief_handled


################################################################################
## PRIVATE VARIABLES
onready var _animator := $AnimationPlayer


################################################################################
## GODOT CALLBACKS
func _ready():
	add_to_group("thieves")
	_animator.play("Idle")
	_animator.connect("animation_finished", self, "_on_animation_finished")


################################################################################
## PUBLIC FUNCTIONS
func interact(_interactor : Node2D) -> void:
	emit_signal("thief_handled")
	interactable = false
	_animator.play("Death")


################################################################################
## SIGNAL CALLBACKS
func _on_animation_finished(value : String) -> void:
	if value == "Death":
		hide()
