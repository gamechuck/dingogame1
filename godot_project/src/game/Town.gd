class_name classTown, "res://assets/textures/class_icons/classTown.png"
extends Node2D

################################################################################
## CONSTANTS
const SCENE_PLAYER := preload("res://src/game/characters/Player.tscn")


################################################################################
## PRIVATE VARIABLES
onready var _players := $Sorted/Characters/Players
onready var _npcs := $Sorted/Characters/NPCs
onready var _interactables_root := $Sorted/Objects
onready var _player_spawn_point := $Misc/PlayerSpawnPoint

var _interactables := []


################################################################################
## GODOT CALLBACKS
func _ready():
	_spawn_level()
	_spawn_npcs()
	_spawn_player()
	_spawn_interactables()
	_connect_signals()

	State.set_loaded_town(self)


################################################################################
## PUBLIC FUNCTIONS
func get_player() -> classPlayer:
	return _players.get_child(0) as classPlayer


################################################################################
## PRIVATE FUNCTIONS
func _connect_signals() -> void:
	var players := get_tree().get_nodes_in_group("players")
#	var characters := get_tree().get_nodes_in_group("characters")
	var npcs := get_tree().get_nodes_in_group("npcs")

	# players
	for player in players:
		player.connect("died", self, "_on_player_died")
#		player.connect("overlay_update_requested", State, "_on_player_overlay_update_requested")

	# characters
#	for character in characters:
#		character.connect("closest_object_requested", self, "_on_closest_object_requested", [character])

	# npcs
	for npc in npcs:
		npc.connect("died", self, "_on_npc_died", [npc])

## SPAWNING
func _spawn_level() -> void:
	pass

func _spawn_player() -> void:
	var player := SCENE_PLAYER.instance()
	_players.add_child(player)
	_players.global_position = _player_spawn_point.global_position
	pass

func _spawn_npcs() -> void:
	pass

func _spawn_interactables() -> void:
	pass
