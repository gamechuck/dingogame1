class_name classWeaponBarrel
extends classContainer

func _ready() -> void:
	add_to_group("weapon_barrels")

func sabotage(_interactor : Node2D) -> void:
	remove_all_items()
	.sabotage(_interactor)
