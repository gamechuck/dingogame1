class_name classTown
extends Node2D

################################################################################
## CONSTANTS
const SCENE_PLAYER := preload("res://src/game/characters/Player.tscn")
const SCENE_BUILDING := preload("res://src/game/Building.tscn")

################################################################################
## PRIVATE VARIABLES
onready var _buildings_root := $Objects/Buildings
onready var _players_root := $Objects/Players
onready var _npcs_root := $Objects/NPCs
onready var _interactables_root := $Objects/Interactables
onready var _props_root  := $Objects/Props
onready var _player_spawn_point := $Misc/PlayerSpawnPoint
onready var _camera := $Camera2D

# EXTERNAL DATA
var _negative_layers_data := []


# BUILDING LAYERS
var _negative_layers := []

# BUILDING SPAWN STUFF
var _building_batch_amount := 1004
var _building_last_spawn_position := Vector2.ZERO
var _building_offset_random_delta := Vector2(0, 50)

# PLAYER STUFF
var _player : classPlayer


################################################################################
## GODOT CALLBACKS
func _ready():
	_set_data()
	_spawn_level()

	_player.connect("position_update", self, "_on_player_position_update")
	_player.emit_signal("position_update", _player.global_position)

#func _process(delta):
#	_move_building_layers(delta)

################################################################################
## PRIVATE FUNCTIONS
func _set_data() -> void:
	_negative_layers_data = Flow.layer_data.get("layers").get("negative", {})
## SPAWNING
func _spawn_level() -> void:
	_spawn_buildings()
	_spawn_player()
	_spawn_npcs()
	_spawn_interactables()

func _spawn_buildings() -> void:
	# Positive layers buildings spawning is not yet implemented since we don't need anything
	# in front of player, but who knows in future
	#var positive_layers := _buildings_root.get_node("Positive").get_children()
	_negative_layers = _buildings_root.get_node("Negative").get_children()
	if _negative_layers_data.size() > _negative_layers.size():
		print("Can't spawn layers, not enough layer nodes!")
		return
	var layer_index = _negative_layers_data.size()
	for layer_data in _negative_layers_data:
		layer_index -= 1

		var last_spawn_position = 0
		var z_order = layer_data.get("z_index", 0)
		_negative_layers[layer_index].z_index = z_order

		if not layer_data.get("should_spawn", true):
			continue

		var y_offset = layer_data.get("y_offset", 0)

		for j in _building_batch_amount:
			var collidable : bool = layer_data.get("collidable", true)
			var textures = layer_data.get("textures", [])
			var random_texture : Texture = load("res://assets/Graphics/Map/" + textures[rand_range(0, textures.size())] + ".png")
			var offset := Vector2(rand_range(_building_offset_random_delta.x, _building_offset_random_delta.y), y_offset)
			var building := SCENE_BUILDING.instance()
			var spawn_position := Vector2(last_spawn_position, 0) + offset + Vector2(random_texture.get_width() * building.scale.x, 0)
			_negative_layers[layer_index].add_child(building)

			building.set_data({"position": spawn_position, "texture": random_texture, "collidable": collidable})
			last_spawn_position = spawn_position.x

func _spawn_player() -> void:
	_player = SCENE_PLAYER.instance()
	_players_root.add_child(_player)
	_player.global_position = _player_spawn_point.global_position
	pass

func _spawn_npcs() -> void:
	pass

func _spawn_interactables() -> void:
	pass

func _move_building_layers(delta : float) -> void:
	for i in _negative_layers.size():
		var layer_parallax_speed = _negative_layers_data[i].get("parallax_speed", 0.0)
		_negative_layers[i].position -= Vector2.RIGHT * delta * layer_parallax_speed


################################################################################
## SIGNAL CALLBACKS
func _on_player_position_update(new_position : Vector2) -> void:
	if new_position.x >= _player_spawn_point.global_position.x:
		_camera.global_position = Vector2(new_position.x, _camera.global_position.y)

