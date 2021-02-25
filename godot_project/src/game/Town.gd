class_name classTown
extends Node2D


################################################################################
## CONSTANTS
const SCENE_PLAYER := preload("res://src/game/Player.tscn")
const SCENE_BUILDING := preload("res://src/game/Building.tscn")
const SCENE_TRAFO := preload("res://src/game/interactables/Trafo.tscn")
const SCENE_THIEF := preload("res://src/game/Thief.tscn")


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
var _game_data := {
	"scores": {
		"trafo": 10.0,
		"thief": 20.0
	}
}
var _negative_layers_data := []
# BUILDING LAYERS
var _negative_layers := []
# BUILDING SPAWN STUFF
var _building_batch_amount := 33
var _building_start_spawn_position_x = -100
var _building_offset_random_delta := Vector2(0, 50)
var _building_parallax_direction = 0
var _buildings_with_trafos := []
var _can_update_parallax := true
# INTERACTABLES STUFF
var _interactables_layers := []
# NPCS STUFF
var _npc_layers := []
var _player : classPlayer


################################################################################
## PROPERTY VARIABLES
var _thief_score := 0.0 setget , get_thief_score
func get_thief_score() -> float:

	return _thief_score
var _trafo_score := 0.0 setget , get_trafo_score
func get_trafo_score() -> float:
	return _trafo_score


################################################################################
## GODOT CALLBACKS
func _ready():
	_set_data()
	_spawn_buildings()
	_spawn_interactables()
	_spawn_player()

func _process(delta):
	if _player and _player.is_moving and _can_update_parallax:
		_move_building_layers(delta)
		_move_interactable_layers(delta)
		_move_npcs_layers(delta)


################################################################################
## PRIVATE FUNCTIONS
func _set_data() -> void:
	_negative_layers_data = Flow.layer_data.get("layers").get("negative", {})
	_can_update_parallax = true

## SPAWNING
func _spawn_buildings() -> void:
	# Positive layers buildings spawning is not yet implemented since we don't need anything
	# in front of player, but who knows in future
	_negative_layers = []
	var layer_index = -1
	for layer_data in _negative_layers_data:
		layer_index += 1

		var last_spawn_position = _building_start_spawn_position_x
		var z_order = layer_data.get("z_index", 0)
		var layer_node = Node2D.new()
		layer_node.name = "BuildingLayer=" + str(z_order)
		_negative_layers.append(layer_node)
		_negative_layers[layer_index].z_index = z_order
		_buildings_root.get_node("Negative").add_child(layer_node)
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
	_player.connect("position_update", self, "_on_player_position_update")
	_player.emit_signal("position_update", _player.global_position)
	_player.connect("direction_update", self, "_on_player_direction_update")

func _spawn_interactables() -> void:
	# Go through each bulding layer and get each building from it
	for j in _negative_layers.size():
		# Create new layer node as parent for interactables of this layer
		var interactable_layer = Node2D.new()
		# Set name, z_index and add it to interactables root parent
		_interactables_root.add_child(interactable_layer)
		interactable_layer.z_index = _negative_layers[j].z_index
		interactable_layer.name = "InteractableLayer=" + str(interactable_layer.z_index)
		# Here we get data from about offsets for interactable spawning
		_interactables_layers.append(interactable_layer)
		# Get data from json about spawning frequency for interactables
		var offsets_array = _negative_layers_data[j].get("interactable_delta_random", [])
		# If it is empty, it means we don't want interactables to be spawned in this layer
		if not offsets_array or offsets_array.size() == 0:
			continue
		# We get random offset from array
		var spawn_offset : int = offsets_array[rand_range(0, offsets_array.size())]
		for i in _negative_layers[j].get_children().size():
			# If i divided by offset is divisible, we spawn interactable
			if i > 0 and i % spawn_offset == 0:
				var building = _negative_layers[j].get_child(i)
				var trafo = SCENE_TRAFO.instance()
				trafo.global_position = building.global_position - Vector2(0, building.get_building_height())
				interactable_layer.add_child(trafo)
				_buildings_with_trafos.append(building)
				trafo.connect("trafo_fixed", self, "_on_trafo_fixed")

	for j in _negative_layers.size():
		# Create new layer node as parent for interactables of this layer
		var npc_layer = Node2D.new()
		# Set name, z_index and add it to interactables root parent
		_npcs_root.add_child(npc_layer)
		npc_layer.z_index = _negative_layers[j].z_index
		npc_layer.name = "NpcLayer=" + str(npc_layer.z_index)
		# Here we get data from about offsets for interactable spawning
		_npc_layers.append(npc_layer)
		# Get data from json about spawning frequency for interactables
		var offsets_array = _negative_layers_data[j].get("thieves_delta_random", [])
		# If it is empty, it means we don't want interactables to be spawned in this layer
		if not offsets_array or offsets_array.size() == 0:
			continue
		# We get random offset from array
		var spawn_offset : int = offsets_array[rand_range(0, offsets_array.size())]
		for i in _negative_layers[j].get_children().size():
			# If i divided by offset is divisible, we spawn interactable
			if i > 0 and i % spawn_offset == 0:
				var building = _negative_layers[j].get_child(i)
				# Check if we already spawned trafo on this building
				if _buildings_with_trafos.has(building):
					continue
				var thief = SCENE_THIEF.instance()
				thief.global_position = building.global_position - Vector2(0, building.get_building_height())
				thief.connect("thief_handled", self, "_on_thief_handled")
				npc_layer.add_child(thief)

#PARALLAX STUFF
func _move_building_layers(delta : float) -> void:
	for i in _negative_layers.size():
		var layer_parallax_speed = _negative_layers_data[i].get("parallax_speed", 0.0) * _building_parallax_direction * delta
		_negative_layers[i].global_position.x += layer_parallax_speed

func _move_interactable_layers(delta : float) -> void:
	for i in _interactables_layers.size():
		var layer_parallax_speed = _negative_layers_data[i].get("parallax_speed", 0.0) * _building_parallax_direction * delta
		_interactables_layers[i].global_position.x += layer_parallax_speed

func _move_npcs_layers(delta : float) -> void:
	for i in _npc_layers.size():
		var layer_parallax_speed = _negative_layers_data[i].get("parallax_speed", 0.0) * _building_parallax_direction * delta
		_npc_layers[i].global_position.x += layer_parallax_speed


################################################################################
## SIGNAL CALLBACKS
func _on_game_finished() -> void:
	 _can_update_parallax = false
	 _player.disable()

func _on_player_position_update(new_position : Vector2) -> void:
	var threshold = OS.window_size.x * 0.01 * _camera.zoom.x
	if new_position.x >= _player_spawn_point.global_position.x + threshold:
		_camera.global_position = Vector2(new_position.x, _camera.global_position.y)

func _on_player_direction_update(new_direction : Vector2) -> void:
	if new_direction == Vector2.LEFT:
		_building_parallax_direction = 1
	else:
		_building_parallax_direction = -1

func _on_trafo_fixed() -> void:
	_trafo_score += _game_data.get("scores").get("trafo")

func _on_thief_handled() -> void:
	_thief_score += _game_data.get("scores").get("thief")

