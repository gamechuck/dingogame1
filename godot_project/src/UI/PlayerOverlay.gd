tool
extends Control

onready var _face_rect := $MarginContainer/HUDVBox/HBoxContainer/BackgroundRect/FrameRect/FaceRect
onready var _hp_progress_bar := $MarginContainer/HUDVBox/HBoxContainer/BackgroundRect/TextureProgress

enum SIDE {LEFT = 0, RIGHT = 1}
enum FACE_STATE {ATTACK = 0, RUN = 1, DEFAULT = 2}

# What player does this overlay represent?
var player_index := 0

export(SIDE) var side := SIDE.LEFT setget set_side
func set_side(value : int):
	side = value
	match side:
		SIDE.LEFT:
			$MarginContainer/HUDVBox/HBoxContainer.alignment = BoxContainer.ALIGN_BEGIN
		SIDE.RIGHT:
			$MarginContainer/HUDVBox/HBoxContainer.alignment = BoxContainer.ALIGN_END

# TODO: The player index should be binded to the connection!

func _ready() -> void:
	if Engine.editor_hint:
		pass
	else:
		State.connect("player_overlay_update_requested", self, "_on_overlay_update_requested")
		_hp_progress_bar.max_value = ConfigData.PLAYER_HP_MAX

func _on_overlay_update_requested(value : int, is_attacking := false, is_running := false) -> void:
	if value <= 0:
		_face_rect.texture = FACE_DEAD_TEXTURE
	elif is_attacking:
		_set_texture(value, FACE_STATE.ATTACK)
	elif is_running:
		_set_texture(value, FACE_STATE.RUN)
	else:
		_set_texture(value, FACE_STATE.DEFAULT)
	_hp_progress_bar.value = value

func _set_texture(value: int, face_state : int):
	for dict_value in PLAYER_THUMBNAIL_DICT:
		if value <= dict_value.get("range"):
			_face_rect.texture = dict_value.get(face_state).get("texture")
			break
		else:
			continue

const FACE_DEAD_TEXTURE := preload("res://ndh-assets/UI/HUD/portraits/werewolf/dead.png")

const PLAYER_THUMBNAIL_DICT := [
	{
		"range": 1,
		FACE_STATE.ATTACK: { "texture": preload("res://ndh-assets/UI/HUD/portraits/werewolf/attack_damaged_2.png") },
		FACE_STATE.RUN: { "texture": preload("res://ndh-assets/UI/HUD/portraits/werewolf/run_damaged_2.png") },
		FACE_STATE.DEFAULT: { "texture": preload("res://ndh-assets/UI/HUD/portraits/werewolf/default_damaged_2.png") },
	},
	{
		"range": 2,
		FACE_STATE.ATTACK: { "texture": preload("res://ndh-assets/UI/HUD/portraits/werewolf/attack_damaged_1.png") },
		FACE_STATE.RUN: { "texture": preload("res://ndh-assets/UI/HUD/portraits/werewolf/run_damaged_1.png") },
		FACE_STATE.DEFAULT: { "texture": preload("res://ndh-assets/UI/HUD/portraits/werewolf/default_damaged_1.png") },
	},
	{
		"range": 1000,
		FACE_STATE.ATTACK: { "texture": preload("res://ndh-assets/UI/HUD/portraits/werewolf/attack.png") },
		FACE_STATE.RUN: { "texture": preload("res://ndh-assets/UI/HUD/portraits/werewolf/run.png") },
		FACE_STATE.DEFAULT: { "texture": preload("res://ndh-assets/UI/HUD/portraits/werewolf/default.png") },
	}
 ]

