tool
class_name KeyboardKey
extends Button

const TEXTURE_ENTER := preload("res://assets/textures/keyboard/GCA_UI_key_return.png")
const TEXTURE_SHIFT := preload("res://assets/textures/keyboard/GCA_UI_key_shift.png")
const TEXTURE_SPACE := preload("res://assets/textures/keyboard/GCA_UI_key_spacebar.png")

const TEXT_COLOR_NORMAL := Color.black
const TEXT_COLOR_PRESSED := Color(0.25098, 0.25098, 0.25098)
const TEXT_COLOR_FOCUSED := Color(0.25098, 0.25098, 0.25098)

enum TYPE { CHARACTER, SHIFT, ALT, BACKSPACE, SYMBOLS, SPACE, ENTER, NOTHING }
enum MODE { MAIN, SHIFT, ALT }

onready var _text := $Text
onready var _texture := $Texture
onready var _tween := $Tween

export var main := "" setget set_main
func set_main(v : String) -> void:
	main = v
	_update_text()

export var alt := "" setget set_alt
func set_alt(v : String) -> void:
	alt = v
	_update_text()

export var shift := "" setget set_shift
func set_shift(v : String) -> void:
	shift = v
	_update_text()

export (TYPE) var type = TYPE.CHARACTER setget set_type
func set_type(v : int) -> void:
	type = v
	if _texture and _text:
		match type:
			TYPE.ENTER:
				_text.visible = false
				_texture.texture = TEXTURE_ENTER
			TYPE.SHIFT:
				_text.visible = false
				_texture.texture = TEXTURE_SHIFT
			TYPE.SPACE:
				_text.visible = false
				_texture.texture = TEXTURE_SPACE

var mode : int = MODE.MAIN setget set_mode
func set_mode(v : int) -> void:
	mode = v
	_update_text()

func _ready() -> void:
	set_main(main)
	set_alt(alt)
	set_type(type)

	if Engine.editor_hint:
		pass
	else:
		rect_pivot_offset = rect_size * 0.5
		connect("button_down", self, "_on_button_down")
		connect("button_up", self, "_on_button_up")
		connect("focus_exited", self, "_on_focus_exited")
		connect("focus_entered", self, "_on_focus_entered")

func get_text() -> String:
	return _text.text

func _update_text() -> void:
	if not _text:
		return
	if type == TYPE.CHARACTER:
		match mode:
			MODE.MAIN:
				_text.text = main
			MODE.SHIFT:
				if shift.empty():
					_text.text = main.to_upper()
				else:
					_text.text = shift
			MODE.ALT:
				_text.text = alt
	else:
		_text.text = main

func _on_button_down() -> void:
	var start_scale : Vector2 = (rect_size + Vector2(-12, -12)) / rect_size
	_tween.interpolate_property(self, "rect_scale", rect_scale, start_scale, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_tween.start()
	_text.modulate = TEXT_COLOR_PRESSED
	_texture.modulate = TEXT_COLOR_PRESSED
	#AudioManager.play_sfx("button_down")

func _on_button_up() -> void:
	var start_scale : Vector2 = (rect_size + Vector2(12, 12)) / rect_size
	_tween.interpolate_property(self, "rect_scale", start_scale, Vector2.ONE, 0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_tween.start()
	_text.modulate = TEXT_COLOR_FOCUSED
	_texture.modulate = TEXT_COLOR_FOCUSED
	#AudioManager.play_sfx("button_up")

func _on_focus_entered() -> void:
	_text.modulate = TEXT_COLOR_FOCUSED
	_texture.modulate = TEXT_COLOR_FOCUSED

func _on_focus_exited() -> void:
	_tween.interpolate_property(self, "rect_scale", rect_scale, Vector2.ONE, 0.05, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_tween.start()
	_text.modulate = TEXT_COLOR_NORMAL
	_texture.modulate = TEXT_COLOR_NORMAL
	#AudioManager.play_sfx("joy_move")
