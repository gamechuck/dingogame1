class_name classThief
extends classInteractable

################################################################################
## SIGNALS CALLBACKS
signal thief_handled


################################################################################
## GODOT CALLBACKS
func _ready():
	add_to_group("thieves")


################################################################################
## PUBLIC FUNCTIONS
func interact(_interactor : Node2D) -> void:
	emit_signal("thief_handled")
	interactable = false
	hide()

