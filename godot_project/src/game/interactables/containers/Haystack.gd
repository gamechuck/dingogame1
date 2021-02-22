class_name classHaystack
extends classContainer

func _ready() -> void:
	add_to_group("haystacks")

func push_character(character : Node2D) -> void:
	$WheatParticles.emitting = true
	.push_character(character)

func pop_character() -> Node2D:
	$WheatParticles.emitting = true
	return .pop_character()

func eject_character() -> void:
	$WheatParticles.emitting = true
	.eject_character()
