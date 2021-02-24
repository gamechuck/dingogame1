class_name classBuilding
extends Node2D

################################################################################
## PRIVATE VARIABLES
onready var _sprite := $Sprite
onready var _collision := $CollisionNode
onready var _collision_shape  := $CollisionNode/CollisionShape2D


################################################################################
### GODOT CALLBACKS
func _ready():
	_collision_shape.shape = _collision_shape.shape.duplicate()


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
		var collision_x = _sprite.texture.get_width() / 2.0
		var collision_y = _sprite.texture.get_height()

		_collision_shape.position = Vector2(0.0, -collision_y - 10.0)
		if _collision_shape.shape is RectangleShape2D:
			_collision_shape.shape.extents.x = collision_x
		if _collision_shape.shape is SegmentShape2D:
			_collision_shape.shape.a = Vector2(-collision_x, 0.0)
			_collision_shape.shape.b = Vector2(collision_x, 0.0)
		_collision_shape.one_way_collision = true
	else:
		_collision_shape.set_deferred("disabled", true)
		_collision_shape.hide()
