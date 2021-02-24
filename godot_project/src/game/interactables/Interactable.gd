class_name classInteractable
extends Node2D


################################################################################
## PUBLIC VARIABLES
export var interactable := true


################################################################################
## PRIVATE VARIABLES
onready var _animated_sprite := $AnimatedSprite


################################################################################
## GODOT CALLBACKS
func _ready() -> void:
	add_to_group("interactables")


################################################################################
## PUBLIC FUNCTIONS
func interact(_interactor : Node2D) -> void:
	pass
