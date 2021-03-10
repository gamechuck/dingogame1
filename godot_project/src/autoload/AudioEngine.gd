# AudioEngine autoload to easily start/stop sound effects and background music.
extends Node

###############################################################################
# CONSTANTS
const MUSIC_TRACKS = {
	"background_music": preload("res://assets/audio/BackgroundMusic.wav")
}
const SFX_TRACKS = {
	"bark": preload("res://assets/audio/Bark.wav"),
	"jump": preload("res://assets/audio/Jump.wav"),
	"thief_falling": preload("res://assets/audio/RobberFalling.wav"),
	"sparks": preload("res://assets/audio/SparksLooped.wav")
}
const MAX_SIMULTANEOUS_EFFECTS = 5

###############################################################################
# ONREADY VARS
onready var _music_player := $MusicPlayer


###############################################################################
# PRIVATE VARS
var _effect_players := []


###############################################################################
# GODOT CALLBACKS
func _ready():
	for _i in range(MAX_SIMULTANEOUS_EFFECTS):
		_add_effect()


###############################################################################
# PUBLIC FUNCTIONS
func reset():
	stop_effect()
	stop_music()

func play_music(key : String) -> void:
	var value : AudioStream = MUSIC_TRACKS[key]
	if _music_player.stream != value:
		_music_player.stream = value
		_music_player.play()

func stop_music() -> void:
	if _music_player.playing:
		_music_player.stop()
		_music_player.stream = null

func play_effect(key : String):
	for player in _effect_players:
		if not player.playing:
			player.stream = SFX_TRACKS[key]
			player.play()
			return

func stop_effect() -> void:
	for player in _effect_players:
		if player.playing:
			player.stop()
			player.stream = null


###############################################################################
# PRIVATE FUNCTIONS
func _add_effect():
	var effect_player := AudioStreamPlayer.new()
	$Effects.add_child(effect_player)

	effect_player.bus = "SFX"
	_effect_players.append(effect_player)
