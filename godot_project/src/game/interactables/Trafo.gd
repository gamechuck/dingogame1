class_name classTrafo
extends classInteractable


################################################################################
## PUBLIC VARIABLES
var is_being_fixed := false
var is_fixed := false

################################################################################
## GODOT CALLBACKS
func _ready():
	add_to_group("trafos")
	_animated_sprite.play("broken")
	is_being_fixed = false
	is_fixed = false


################################################################################
## PUBLIC FUNCTIONS
func start_fixing(_interactor : classPlayer) -> void:
	is_being_fixed = true

func finish_fixing(_interactor : classPlayer) -> void:
	is_being_fixed = false


################################################################################
## PRIVATE FUNCTIONS
func _set_data() -> void:
	pass
