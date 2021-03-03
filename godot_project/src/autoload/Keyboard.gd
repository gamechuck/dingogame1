extends CanvasLayer


################################################################################
## SIGNALS
signal input_buffer_changed


################################################################################
## CONSTANTS
const PATH_KEYBOARD_LAYOUTS := "res://data/keyboard_layouts.jsonc"
const SCENE_KEYBOARD := preload("res://src/keyboard/Keyboard.tscn")


################################################################################
## PUBLIC VARIABLES
var clear_input_buffer_on_hide := true

var input_buffer := "" setget set_input_buffer
func set_input_buffer(v : String) -> void:
	input_buffer = v
	emit_signal("input_buffer_changed", input_buffer)

var visible := false setget set_visible
func set_visible(v : bool) -> void:
	visible = v
	if _keyboard:
		_keyboard.visible = v
		if visible:
			_keyboard.focus()
	if clear_input_buffer_on_hide:
		set_input_buffer("")


################################################################################
## PRIVATE VARIABLES
var _keyboard
var _position := Vector2()
# EXTERNAL DATA
var _keyboard_layouts_data := {}


################################################################################
## GODOT CALLBACKS
# warning-ignore:unused_argument
func _input(event : InputEvent) -> void:
#	if Input.is_action_just_pressed("b1") and visible:
#		Controller.block_frame = true
#		set_visible(false)
	if Input.is_action_just_pressed("debug_toggle_keyboard"):
		toggle_visible()

func _ready() -> void:
	# load keyboard layouts json
	_keyboard_layouts_data = Flow.load_json(PATH_KEYBOARD_LAYOUTS)
	build_keyboard_for_locale("en")
	set_visible(false)


################################################################################
## PUBLIC FUNCTIONS
func build_keyboard_for_locale(lang : String) -> void:
	var layouts : Dictionary = _keyboard_layouts_data.get("layouts", {})
	if layouts.empty():
		push_warning("missing \"layouts\" key!")
		return
	if not layouts.has(lang):
		push_warning("missing locale " + lang + "!")
		return

	var layout_data : Dictionary = layouts[lang]
	var keyboard := SCENE_KEYBOARD.instance()
	add_child(keyboard)
	keyboard.build_from_layout_data(layout_data)

	if _keyboard:
		remove_child(_keyboard)
		_keyboard.queue_free()
	_keyboard = keyboard
	_keyboard.connect("key_pressed", self, "_on_key_pressed")

	# refresh keyboard visibility
	set_visible(visible)
	set_keyboard_position(_position)

func set_keyboard_position(pos : Vector2) -> void:
	_position = pos
	if _keyboard:
		_keyboard.rect_position = _position

func toggle_visible() -> void:
	set_visible(not visible)

func remove_char_from_input_buffer() -> void:
	if input_buffer.length() > 0:
		set_input_buffer(input_buffer.substr(0, input_buffer.length() - 1))


################################################################################
## SIGNAL CALLBACKS
func _on_key_pressed(key : KeyboardKey) -> void:
	match key.type:
		KeyboardKey.TYPE.CHARACTER:
			self.input_buffer += key.get_text()
		KeyboardKey.TYPE.SHIFT:
			pass
		KeyboardKey.TYPE.BACKSPACE:
			remove_char_from_input_buffer()
		KeyboardKey.TYPE.SYMBOLS:
			pass
		KeyboardKey.TYPE.SPACE:
			self.input_buffer += " "
		KeyboardKey.TYPE.ENTER:
			set_visible(false)
