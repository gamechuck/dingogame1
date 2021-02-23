class_name classBuilding
extends Node2D

################################################################################
## PRIVATE VARIABLES
onready var _sprite := $Sprite
onready var _collision := $CollisionNode
onready var _collision_shape  := $CollisionNode/CollisionShape2D


################################################################################
## GODOT CALLBACKS
func _ready():
	_set_texture(load("res://assets/Graphics/Map/building_2.png"))
	_set_collision_shape(true)

################################################################################
## PUBLIC FUNCTIONS
func set_data(data_dict : Dictionary) -> void:
	global_position = data_dict.get("position", Vector2.ZERO)
	_set_texture(data_dict.get("texture", null))
	_set_collision_shape(data_dict.get("collidable", true))


################################################################################
## PRIVATE FUNCTIONS
func _set_texture(sprite : Texture) -> void:
	if _sprite:
		_sprite.offset = Vector2(0.0, -(sprite.get_height() / 2.0))
		_sprite.texture = sprite

func _set_collision_shape(collidable : bool) -> void:
	if collidable:
		var collision_y = -_sprite.texture.get_height() + (_collision_shape.shape.extents.y / 2.0)
		_collision_shape.position = Vector2(0.0, collision_y)
		_collision_shape.shape.extents = Vector2(_sprite.texture.get_width() / 2.0, _collision_shape.shape.extents.y)
	else:
		_collision.set_deferred("disabled", true)


