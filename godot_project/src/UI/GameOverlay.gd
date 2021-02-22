# Overlay that is always visible in-game.
extends Control

const MAX_ANGLE := 180.0
onready var _owl_sfx := preload("res://assets/audio/sfx/game/owl.wav")
onready var _rooster_sfx := preload("res://assets/audio/sfx/game/rooster.wav")
onready var _version_label := $MarginContainer/VBoxContainer/VersionLabel
onready var _alive_label := $MarginContainer/HUDVBox/AliveRect/VBoxContainer/AliveLabel
onready var _timewheel := $MarginContainer/HUDVBox/Timewheel
onready var _audio_stream := $AudioStreamPlayer

var _can_update_time_wheel := false
var _current_day_phase := 0
var _current_phase_duration := 0.0
var _current_phase_time := 0.0
var _timewheel_angle := 0.0
var _last_angle := 0.0

func _ready():
	_timewheel_angle = _timewheel.material.get_shader_param("uv_rotation")
	_last_angle = _timewheel_angle
	update_version_label()
	ConfigData.connect("version_visibility_changed", self, "update_version_label")
	State.connect("day_phase_time_updated", self, "_on_day_phase_time_updated")
	State.connect("day_phase_updated", self, "_on_day_phase_updated")
	State.connect("npc_count_alive_changed", self, "update_npcs_alive_label")

func _physics_process(_delta):
	if _can_update_time_wheel:
		_timewheel.material.set_shader_param("uv_rotation", _timewheel_angle)

func update_version_label():
	if ConfigData.show_version:
		_version_label.text = "v{0}.{1} ({2})".format([
			ConfigData.major_version,
			ConfigData.minor_version,
			ConfigData.version_string])
		_version_label.visible = true
	else:
		_version_label.visible = false

func update_npcs_alive_label():
	_alive_label.text = str(State.loaded_town.get_npc_count_alive_for_mission())

func show_end_overlay(game_state : int) -> void:
	match game_state:
		State.GAME_STATE.WIN:
			$EndOverlay.set_game_state(State.GAME_STATE.WIN)
		State.GAME_STATE.LOSE:
			$EndOverlay.set_game_state(State.GAME_STATE.LOSE)
	$EndOverlay.show()

func _on_day_phase_updated(day_phase : int) -> void:
	if day_phase == State.DAY_STATE.DAWN:
		_current_phase_duration = State.loaded_town.town_state.day_phase_state.get("day_phase_duration") + State.get_dawn_duration()
		_timewheel_angle = 0.0
		_current_phase_time = 0.0
		_last_angle = 0.0
	if day_phase == State.DAY_STATE.DAY:
		_current_phase_duration = State.loaded_town.town_state.day_phase_state.get("day_phase_duration") + State.get_dawn_duration()
		_current_phase_time = State.get_dawn_duration()
		_timewheel_angle = (State.get_dawn_duration() / _current_phase_duration) * MAX_ANGLE
	if day_phase == State.DAY_STATE.DUSK:
		_current_phase_duration = State.loaded_town.town_state.day_phase_state.get("night_phase_duration") + State.get_dusk_duration()
		_timewheel_angle = 180.0
		_current_phase_time = 0.0
		_last_angle = 0.0
	if  day_phase == State.DAY_STATE.NIGHT:
		_current_phase_duration = State.loaded_town.town_state.day_phase_state.get("night_phase_duration") + State.get_dusk_duration()
		_current_phase_time = State.get_dusk_duration()
		_timewheel_angle = 180.0 + ((State.get_dusk_duration() / _current_phase_duration) * MAX_ANGLE)

	_current_day_phase = day_phase
	_can_update_time_wheel = true
	if day_phase == State.DAY_STATE.DAWN:
		_audio_stream.stream = _rooster_sfx
		_audio_stream.play()
	if day_phase == State.DAY_STATE.DUSK:
		_audio_stream.stream = _owl_sfx
		_audio_stream.play()

func _on_day_phase_time_updated(time : float) -> void:
	var angle =  (time / _current_phase_duration) * MAX_ANGLE
	_timewheel_angle += (angle - _last_angle)
	_last_angle = angle

