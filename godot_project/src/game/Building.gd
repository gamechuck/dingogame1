class_name classBuilding
extends Node2D

################################################################################
## PRIVATE VARIABLES
onready var _sprite := $Sprite
onready var _collision := $CollisionNode
onready var _collision_shape  := $CollisionNode/CollisionShape2D

onready var _side_detection_collision := $PlayerDetectArea
onready var _side_collision_shape  := $PlayerDetectArea/CollisionShape2D


################################################################################
### GODOT CALLBACKS
func _ready():
	_collision_shape.shape = _collision_shape.shape.duplicate()
	_side_collision_shape.shape = _side_collision_shape.shape.duplicate()


################################################################################
## PUBLIC FUNCTIONS
func set_data(data_dict : Dictionary) -> void:
	global_position = data_dict.get("position", Vector2.ZERO)
	_set_texture(data_dict.get("texture", null))
	_set_collision_shape(data_dict.get("collidable", true))
	_side_detection_collision.connect("body_entered", self, "_on_player_entered")
	_side_detection_collision.connect("body_exited", self, "_on_player_exited")

func get_building_height() -> float:
	if not _sprite or not _sprite.texture:
		return 0.0
	return _sprite.texture.get_size().y * scale.y

func get_building_width_halved() -> float:
	if not _sprite or not _sprite.texture:
		return 0.0
	return _sprite.texture.get_size().y * scale.x


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
		_side_collision_shape.position = _collision_shape.position
		_side_collision_shape.shape.extents.x = collision_x + 10.0
	else:
		_collision_shape.set_deferred("disabled", true)
		_collision_shape.hide()
		_side_collision_shape.set_deferred("disabled", true)
		_side_collision_shape.hide()


################################################################################
## SIGNAL CALLBACKS
func _on_player_entered(player : Node2D) -> void:
	if player.global_position.y < _collision.global_position.y + _collision_shape.shape.extents.y:
		if player.global_position.x > 0 and player.global_position.x >= global_position.x + get_building_width_halved():
			_side_collision_shape.set_deferred("disabled", true)
		if player.global_position.x < 0 and player.global_position.x <= global_position.x - get_building_width_halved():
			_side_collision_shape.set_deferred("disabled", true)

func _on_player_exited(_body : Node2D) -> void:
	_side_collision_shape.set_deferred("disabled", false)

#
