class_name classBuilding
extends Node2D


################################################################################
## PRIVATE VARIABLES
onready var _sprite := $Sprite
onready var _collision := $CollisionStaticBody
onready var _collision_shape  := $CollisionStaticBody/CollisionShape2D
onready var _side_detection := $SideDetectionArea
onready var _side_detection_shape := $SideDetectionArea/CollisionShape2D


################################################################################
### GODOT CALLBACKS
func _ready():
	_collision_shape.shape = _collision_shape.shape.duplicate()
	_side_detection_shape.shape = _side_detection_shape.shape.duplicate()
	_side_detection.connect("body_entered", self, "_on_side_detect_area_body_entered")
	_side_detection.connect("body_exited", self, "_on_side_detect_area_body_exited")


################################################################################
## PUBLIC FUNCTIONS
func set_data(data_dict : Dictionary) -> void:
	global_position = data_dict.get("position", Vector2.ZERO)
	_set_texture(data_dict.get("texture", null))
	_set_collision_shape(data_dict.get("collidable", true))

func get_building_height() -> float:
	if not _sprite or not _sprite.texture:
		return 0.0
	return _sprite.texture.get_size().y * scale.y

func get_building_width() -> float:
	if not _sprite or not _sprite.texture:
		return 0.0
	return _sprite.texture.get_size().x * scale.x


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

		_collision_shape.position = Vector2(0.0, -collision_y + 100.0)
		if _collision_shape.shape is RectangleShape2D:
			_collision_shape.shape.extents.x = collision_x
		if _collision_shape.shape is SegmentShape2D:
			_collision_shape.shape.a = Vector2(-collision_x, 0.0)
			_collision_shape.shape.b = Vector2(collision_x, 0.0)

		_collision_shape.one_way_collision = true
		_side_detection_shape.one_way_collision = true
		_side_detection_shape.position.x = 0
		_side_detection_shape.position.y = _collision_shape.position.y + 10.0
		_side_detection_shape.shape.extents.x = _collision_shape.shape.extents.x * 1.4
		_side_detection_shape.shape.extents.y = _collision_shape.shape.extents.y * 0.8
	else:
		_collision_shape.set_deferred("disabled", true)
		_collision_shape.hide()

		_side_detection_shape.set_deferred("disabled", true)
		_side_detection_shape.hide()

func _on_side_detect_area_body_entered(_body : Node2D) -> void:
		if _body.global_position.x < _side_detection_shape.global_position.x - get_building_width() / 2.0:
			_collision.set_collision_layer_bit(4, false)
		if _body.global_position.x > _side_detection_shape.global_position.x + get_building_width() / 2.0:
			_collision.set_collision_layer_bit(4, false)

func _on_side_detect_area_body_exited(_body : Node2D) -> void:
	_collision.set_collision_layer_bit(4, true)


