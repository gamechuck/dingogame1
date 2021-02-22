# AudioEngine autoload to easily start/stop sound effects and background music.
extends Node

const MUSIC_TRACKS = {
	"town_idle": preload("res://assets/audio/music/town_idle_loop.ogg"),
	"town_vigilant": preload("res://assets/audio/music/town_vigilant_loop.ogg"),
	"main_menu": preload("res://assets/audio/music/main_menu_loop.ogg")
}

const AMBIENT_TRACKS = {
	"night_ambient": preload("res://assets/audio/ambient/night_ambient_loop.ogg")
}

const SFX_TRACKS = {
	"door_open": preload("res://assets/audio/sfx/game/door_open.wav")
}

onready var _music_player := $MusicPlayer
onready var _ambient_player := $AmbientPlayer
onready var _effects := $Effects

export var MAX_SIMULTANEOUS_EFFECTS = 5

func _ready():
	for _i in range(MAX_SIMULTANEOUS_EFFECTS):
		_effects.add_effect()

func play_effect(key : String):
	_effects.play_effect(SFX_TRACKS[key])

func reset():
	_effects.reset()
	stop_music()
	stop_ambient()

func play_music(key : String) -> void:
	var value : AudioStream = MUSIC_TRACKS[key]
	if _music_player.stream != value:
		_music_player.stream = value
		_music_player.play()

func stop_music() -> void:
	if _music_player.playing:
		_music_player.stop()
		_music_player.stream = null

func play_ambient(key : String) -> void:
	var value : AudioStream = AMBIENT_TRACKS[key]
	if _ambient_player.stream != value:
		_ambient_player.stream = value
		_ambient_player.play()

func stop_ambient() -> void:
	if _ambient_player.playing:
		_ambient_player.stop()
		_ambient_player.stream = null
