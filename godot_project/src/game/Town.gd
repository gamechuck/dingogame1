class_name classTown
extends Node2D


################################################################################
## CONSTANTS
const SCENE_PLAYER := preload("res://src/game/Player.tscn")
const SCENE_BUILDING := preload("res://src/game/Building.tscn")
const SCENE_TRAFO := preload("res://src/game/interactables/Trafo.tscn")
const SCENE_THIEF := preload("res://src/game/Thief.tscn")
# PROPS SCENES
const SCENE_LIGHT_POLE := preload("res://src/game/props/LightPole.tscn")
const SCENE_WINDMILL  := preload("res://src/game/props/Windmill.tscn")
const SCENE_SOLAR_PANEL := preload("res://src/game/props/SolarPanel.tscn")
const SCENE_POWER_UP := preload("res://src/game/PowerUp.tscn")

################################################################################
## PRIVATE VARIABLES
onready var _buildings_root := $Objects/Buildings
onready var _players_root := $Objects/Players
onready var _npcs_root := $Objects/NPCs
onready var _interactables_root := $Objects/Interactables
onready var _power_ups_root := $Objects/PowerUps
onready var _props_root  := $Objects/Props
onready var _player_spawn_point := $Misc/PlayerSpawnPoint
onready var _camera := $PlayerCamera2D
onready var _terrain := $Terrain
onready var _tween := $Tween

# EXTERNAL DATA
var _game_data := {}
var _building_layers_data := []
# BUILDING LAYERS AND SPAWN STUFF
var _building_layers := []
var _building_batch_amount := 2
var _building_start_spawn_position_x = -100
var _building_offset_random_delta := [0, 50]
var _building_parallax_direction = 0
var _buildings_with_trafos := []
var _can_update_parallax := true
# INTERACTABLES STUFF
var _interactables_layers := []
# NPCS STUFF
var _npc_layers := []
var _power_ups_layers := []
# PROP STUFF
var _prop_layers := []
var _props_dict := {
	"light_pole": SCENE_LIGHT_POLE,
	"windmill": SCENE_WINDMILL,
	"solar_panel": SCENE_SOLAR_PANEL
}

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
	_spawn_props()
	_camera.global_position = Vector2(_player.global_position.x, _camera.global_position.y)

func _process(delta):
	if _player and _player.is_moving and _can_update_parallax:
		_move_building_layers(delta)
		_move_interactable_layers(delta)
		_move_npcs_layers(delta)
		_move_props_layers(delta)
		_move_power_ups_layers(delta)


################################################################################
## PRIVATE FUNCTIONS
func _set_data() -> void:
	_game_data = Flow.game_data
	var camera_zoom = _game_data.get("camera_zoom")
	_camera.zoom = Vector2(camera_zoom[0], camera_zoom[1])
	_camera.offset.y = _game_data.get("camera_offset_y")
	var random_offset = _game_data.get("building_offset_random_delta", [0, 50])
	_building_offset_random_delta = random_offset
	_building_batch_amount = _game_data.get("building_batch_amount", 100)
	_building_start_spawn_position_x = _game_data.get("building_starting_x", 100)

	_building_layers_data = Flow.layer_data.get("negative", {})
	_can_update_parallax = true

## SPAWNING
func _spawn_buildings() -> void:
	# Positive layers buildings spawning is not yet implemented since we don't need anything
	# in front of player, but who knows in future
	_building_layers = []
	var layer_index = -1
	for layer_data in _building_layers_data:
		layer_index += 1
		_building_batch_amount = layer_data.get("batch_amount", 0)
		_building_offset_random_delta = layer_data.get("offset_random_delta")
		var last_spawn_position = layer_data.get("starting_x", -100.0)
		var z_order = layer_data.get("z_index", 0)
		var layer_node = Node2D.new()
		layer_node.name = "BuildingLayer=" + str(z_order)
		_building_layers.append(layer_node)
		_building_layers[layer_index].z_index = z_order
		_buildings_root.add_child(layer_node)
		if not layer_data.get("should_spawn", true):
			continue

		var y_offset = _terrain.global_position.y - 15.0 + layer_data.get("y_offset", 0)

		for j in _building_batch_amount:
			var collidable : bool = layer_data.get("collidable", true)
			var textures = layer_data.get("building_textures", [])
			var random_texture : Texture = load("res://assets/Graphics/Map/" + textures[rand_range(0, textures.size())] + ".png")
			var offset := Vector2(rand_range(_building_offset_random_delta[0], _building_offset_random_delta[1]), y_offset)
			var building := SCENE_BUILDING.instance()
			var spawn_position := Vector2(last_spawn_position, 0) + offset + Vector2(random_texture.get_width() * building.scale.x, 0)
			_building_layers[layer_index].add_child(building)

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
	_spawn_trafos()
	_spawn_thieves()
	_spawn_power_ups()

func _spawn_trafos() -> void:
	# Go through each bulding layer and get each building from it
	for j in _building_layers.size():
		# Create new layer node as parent for interactables of this layer
		var interactable_layer = Node2D.new()
		# Set name, z_index and add it to interactables root parent
		_interactables_root.add_child(interactable_layer)
		interactable_layer.z_index = _building_layers[j].z_index
		interactable_layer.name = "InteractableLayer=" + str(interactable_layer.z_index)
		# Here we get data from about offsets for interactable spawning
		_interactables_layers.append(interactable_layer)
		# Get data from json about spawning frequency for interactables
		var offsets_array = _building_layers_data[j].get("interactable_delta_random", [])
		# If it is empty, it means we don't want interactables to be spawned in this layer
		if not offsets_array or offsets_array.size() == 0:
			continue
		# We get random offset from array
		var spawn_offset : int = offsets_array[rand_range(0, offsets_array.size())]
		for i in _building_layers[j].get_children().size():
			# If i divided by offset is divisible, we spawn interactable
			if i > 0 and i % spawn_offset == 0:
				var building = _building_layers[j].get_child(i)
				var trafo = SCENE_TRAFO.instance()
				interactable_layer.add_child(trafo)
				trafo.global_position = building.global_position + Vector2(10.0, -building.get_building_height())
				trafo.connect("trafo_fixed", self, "_on_trafo_fixed")
				_buildings_with_trafos.append(building)

func _spawn_thieves() -> void:
	for j in _building_layers.size():
		# Create new layer node as parent for interactables of this layer
		var npc_layer = Node2D.new()
		# Set name, z_index and add it to interactables root parent
		_npcs_root.add_child(npc_layer)
		npc_layer.z_index = _building_layers[j].z_index
		npc_layer.name = "NpcLayer=" + str(npc_layer.z_index)
		# Here we get data from about offsets for interactable spawning
		_npc_layers.append(npc_layer)
		# Get data from json about spawning frequency for interactables
		var offsets_array = _building_layers_data[j].get("thieves_delta_random", [])
		# If it is empty, it means we don't want interactables to be spawned in this layer
		if not offsets_array or offsets_array.size() == 0:
			continue
		# We get random offset from array
		var spawn_offset : int = offsets_array[rand_range(0, offsets_array.size())]
		for i in _building_layers[j].get_children().size():
			# If i divided by offset is divisible, we spawn interactable
			if i > 0 and i % spawn_offset == 0:
				var building = _building_layers[j].get_child(i)
				# Check if we already spawned trafo on this building, if not thief can't be spawned
				if not _buildings_with_trafos.has(building):
					continue
				var thief = SCENE_THIEF.instance()
				npc_layer.add_child(thief)
				thief.global_position = building.global_position + Vector2(-10.0, -building.get_building_height())
				thief.connect("thief_handled", self, "_on_thief_handled")

func _spawn_power_ups() -> void:
	for j in _building_layers.size():
		# Create new layer node as parent for interactables of this layer
		var power_up_layer = Node2D.new()
		# Set name, z_index and add it to interactables root parent
		_power_ups_root.add_child(power_up_layer)
		power_up_layer.z_index = _building_layers[j].z_index
		power_up_layer.name = "PowerUpLayer=" + str(power_up_layer.z_index)
		# Here we get data from about offsets for interactable spawning
		_power_ups_layers.append(power_up_layer)
		# Get data from json about spawning frequency for interactables
		var offsets_array = _building_layers_data[j].get("power_ups_delta_random", [])
		# If it is empty, it means we don't want interactables to be spawned in this layer
		if not offsets_array or offsets_array.size() == 0:
			continue
		# We get random offset from array
		var spawn_offset : int = offsets_array[rand_range(0, offsets_array.size())]
		for i in _building_layers[j].get_children().size():
			# If i divided by offset is divisible, we spawn interactable
			if i > 0 and i % spawn_offset == 0:
				var building = _building_layers[j].get_child(i)
				# Check if we already spawned trafo on this building, if not thief can't be spawned
				if not _buildings_with_trafos.has(building):
					continue
				var power_up = SCENE_POWER_UP.instance()
				power_up_layer.add_child(power_up)
				power_up.global_position = building.global_position + Vector2(-10.0, -building.get_building_height() + rand_range(-50, 0))

func _spawn_props() -> void:
	for j in _building_layers.size():
		# Create new layer node as parent for interactables of this layer
		var prop_layer = Node2D.new()
		var props_data = _building_layers_data[j].get("props_data", {})

		# Set name, z_index and add it to interactables root parent
		_props_root.add_child(prop_layer)
		prop_layer.z_index = _building_layers[j].z_index
		prop_layer.name = "PropLayer=" + str(prop_layer.z_index)
		# Here we get data from about offsets for interactable spawning
		_prop_layers.append(prop_layer)

		if not props_data or props_data.empty():
			continue

		var prop_scenes_keys = props_data.get("prop_scenes")

		if not prop_scenes_keys or prop_scenes_keys.empty():
			continue

		var is_on_ground = props_data.get("is_on_ground", false)
		var prop_deltas = props_data.get("prop_delta_random", [])
		var prop_delta : int = 1

		for i in _building_layers[j].get_children().size():
			var building = _building_layers[j].get_child(i)
			if not is_on_ground and _buildings_with_trafos.has(building):
				continue
			if prop_deltas and prop_deltas.size() > 0:
				prop_delta = prop_deltas[rand_range(0, prop_deltas.size())]
			if i % prop_delta == 0:
				var prop_scene = _props_dict[prop_scenes_keys[rand_range(0, prop_scenes_keys.size())]]
				var prop = prop_scene.instance()
				prop_layer.add_child(prop)
				if is_on_ground:
					prop.global_position = building.global_position + Vector2(building.get_building_width () / 2.0 + prop.get_width() / 2.0, 0)
				else:
					prop.global_position = building.global_position + Vector2(0, -building.get_building_height())

#PARALLAX STUFF
func _move_building_layers(delta : float) -> void:
	for i in _building_layers.size():
		var layer_parallax_speed = _building_layers_data[i].get("parallax_speed", 0.0) * _building_parallax_direction * delta
		_building_layers[i].global_position.x += layer_parallax_speed

func _move_interactable_layers(delta : float) -> void:
	for i in _interactables_layers.size():
		var layer_parallax_speed = _building_layers_data[i].get("parallax_speed", 0.0) * _building_parallax_direction * delta
		_interactables_layers[i].global_position.x += layer_parallax_speed

func _move_npcs_layers(delta : float) -> void:
	for i in _npc_layers.size():
		var layer_parallax_speed = _building_layers_data[i].get("parallax_speed", 0.0) * _building_parallax_direction * delta
		_npc_layers[i].global_position.x += layer_parallax_speed

func _move_props_layers(delta : float) -> void:
	for i in _prop_layers.size():
		var layer_parallax_speed = _building_layers_data[i].get("parallax_speed", 0.0) * _building_parallax_direction * delta
		_prop_layers[i].global_position.x += layer_parallax_speed

func _move_power_ups_layers(delta : float) -> void:
	for i in _power_ups_layers.size():
		var layer_parallax_speed = _building_layers_data[i].get("parallax_speed", 0.0) * _building_parallax_direction * delta
		_power_ups_layers[i].global_position.x += layer_parallax_speed

################################################################################
## SIGNAL CALLBACKS
func _on_game_finished() -> void:
	_can_update_parallax = false
	_player.disable()
	_camera.zoom = Vector2.ONE
	_camera.global_position = OS.get_real_window_size() / 2.0

func _on_player_position_update(new_position : Vector2) -> void:
	if new_position.x >= _player_spawn_point.global_position.x:
		_can_update_parallax = true
		_tween.interpolate_property(_camera, "global_position", _camera.global_position, Vector2(new_position.x, _camera.global_position.y), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_tween.start()
	else:
		_can_update_parallax = false

func _on_player_direction_update(new_direction : Vector2) -> void:
	if new_direction == Vector2.LEFT:
		_building_parallax_direction = 1
	else:
		_building_parallax_direction = -1

func _on_trafo_fixed() -> void:
	_trafo_score += _game_data.get("scores").get("trafo")

func _on_thief_handled() -> void:
	_thief_score += _game_data.get("scores").get("thief")

