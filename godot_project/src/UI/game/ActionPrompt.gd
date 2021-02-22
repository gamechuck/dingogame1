tool
extends HBoxContainer

onready var _label := $MC/MC/HB/Label
onready var _button_texture_rect := $MC/MC/HB/ButtonTextureRect

export var text := "<text>" setget set_text
func set_text(v : String) -> void:
	text = v
	if _label:
		_label.text = v

export var button_texture : Texture setget set_button_texture
func set_button_texture(v : Texture) -> void:
	button_texture = v
	if _button_texture_rect:
		_button_texture_rect.texture = button_texture

func _ready() -> void:
	set_text(text)
	set_button_texture(button_texture)
