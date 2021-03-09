class_name classThief
extends classInteractable

################################################################################
## SIGNALS CALLBACKS
signal thief_handled


################################################################################
## PRIVATE VARIABLES
onready var _animator := $AnimationPlayer

var _fall_down := false
var _fall_start_y := 0.0

################################################################################
## GODOT CALLBACKS
func _ready():
	add_to_group("thieves")
	_animator.play("Idle")

func _physics_process(delta):
	if _fall_down:
		global_position.y += (delta * 200.0)
		if global_position.y > _fall_start_y + 200.0:
			hide()


################################################################################
## PUBLIC FUNCTIONS
func interact(_interactor : Node2D) -> void:
	emit_signal("thief_handled")
	interactable = false
	_animator.play("Death")
	_fall_down = true
	_fall_start_y = global_position.y
	z_as_relative = false
	z_index = 0



