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

# BUILDING SPAWN STUFF
var _building_batch_amount := 10
var _building_last_spawn_position := Vector2.ZERO
var _building_spawn_offset := 200
var _building_offset_random_delta := Vector2(-50, 50)

# PLAYER STUFF
var _player : classPlayer


################################################################################
## GODOT CALLBACKS
func _ready():
	_negative_layers_data = Flow.layer_data.get("layers").get("negative", {})
	_spawn_level()

	_player.connect("position_update", self, "_on_player_position_update")
	_player.emit_signal("position_update", _player.global_position)


################################################################################
## PRIVATE FUNCTIONS
## SPAWNING
func _spawn_level() -> void:
#	_spawn_buildings()
	_spawn_player()
#	_spawn_npcs()
#	_spawn_interactables()
#	_connect_signals()

func _spawn_buildings() -> void:
	# Positive layers buildings spawning is not yet implemented since we don't need anything
	# in front of player, but who knows in future
	#var positive_layers := _buildings_root.get_node("Positive").get_children()
	var negative_layers := _buildings_root.get_node("Negative").get_children()
	var layer_index = 0
	for layer_data in _negative_layers_data:
		if not layer_data.get("should_spawn", true):
			continue

		var last_spawn_position := Vector2.ZERO
		var z_order = layer_data.get("z_index", 0)
		var negative_layer_node = negative_layers[layer_index]
		negative_layer_node.z_index = z_order
		layer_index += 1

		for j in _building_batch_amount:
			var offset := Vector2(_building_spawn_offset, 0) + Vector2(rand_range(_building_offset_random_delta.x, _building_offset_random_delta.y), 0)
			var spawn_position := last_spawn_position + offset
			var building := SCENE_BUILDING.instance()
			var textures = layer_data.get("textures", [])
			var random_texture := load("res://assets/Graphics/Map/" + textures[rand_range(0, textures.size())] + ".png")
			var collidable : bool = layer_data.get("collidable", true)
			negative_layer_node.add_child(building)
			building.position = Vector2.ZERO
			building.set_data({"position": spawn_position, "texture": random_texture, "collidable": collidable})
			last_spawn_position = spawn_position

func _spawn_player() -> void:
	_player = SCENE_PLAYER.instance()
	_players_root.add_child(_player)
	_player.global_position = _player_spawn_point.global_position
	pass

func _spawn_npcs() -> void:
	pass

func _spawn_interactables() -> void:
	pass

################################################################################
## PRIVATE FUNCTIONS
func _on_player_position_update(new_position : Vector2) -> void:
	if new_position.x >= _player_spawn_point.global_position.x:
		_camera.global_position = Vector2(new_position.x, _camera.global_position.y)

