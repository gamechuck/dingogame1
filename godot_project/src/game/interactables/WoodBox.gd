class_name classWoodBox
extends classInteractable

################################################################################
## INSPECTOR VARIABLES

export var max_amount := 3

################################################################################
## PRIVATE VARIABLES

var _current_amount := 0

################################################################################
## GODOT CALLBACKS

func _ready() -> void:
	add_to_group("wood_gather_spots")

################################################################################
## PUBLIC FUNCTIONS
# Overrides
func finish_sabotage(_sabotager : Node2D) -> void:
	_current_amount = 0
	.finish_sabotage(_sabotager)

# Checks
func is_empty() -> bool:
	return _current_amount <= 0

func is_full() -> bool:
	return _current_amount >= max_amount

func change_amount(value : int) -> void:
	if is_full():
		return
	_current_amount += value
