extends classInteractable

func _ready() -> void:
	add_to_group("fireplaces")

func get_sprite_offset() -> Vector2:
	return $AnimatedSprite.offset
