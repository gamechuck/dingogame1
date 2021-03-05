extends Control

################################################################################
## SIGNALS
signal key_pressed #(key)


################################################################################
## CONSTANTS
var SCENE_KEYBOARD_KEY := preload("res://src/keyboard/KeyboardKey.tscn")


################################################################################
## PUBLIC VARIABLES
var shift_keys := []
var alt_keys := []

var shift_pressed := false
var alt_pressed := false

var first_key : KeyboardKey


################################################################################
## PRIVATE VARIABLES
onready var _rows_container := $KeyboardRoot/RowsContainer


################################################################################
## GODOT CALLBACKS
func _ready() -> void:
	visible = false


################################################################################
## PUBLIC FUNCTIONS
func focus() -> void:
	if first_key:
		first_key.grab_focus()

func build_from_layout_data(layout_data : Dictionary) -> void:
	var row_count : int = layout_data["rows"].size()
	var horizontal_separation : int = layout_data.get("horizontal_separation", 0)
# warning-ignore:unused_variable
	var vertical_separation : int = layout_data.get("vertical_separation", 0)
	var key_width : int = layout_data.get("key_width", 60)
	var key_height : int = layout_data.get("key_height", 60)

	for i in row_count:
		# add row
		var row := HBoxContainer.new()
		row.set("custom_constants/separation", horizontal_separation)
		row.size_flags_horizontal = row.SIZE_EXPAND_FILL
		row.size_flags_vertical = row.SIZE_EXPAND_FILL
		row.alignment = BoxContainer.ALIGN_CENTER
		_rows_container.add_child(row)

		# add keys
		var row_data : Dictionary = layout_data["rows"][i]
		var keys_data : Array = row_data["keys"]

		for key_data in keys_data:
			var key : KeyboardKey = SCENE_KEYBOARD_KEY.instance()
			match key_data["type"]:
				"char":
					key.type = KeyboardKey.TYPE.CHARACTER
					key.set_main(key_data["main"])
					key.set_alt(key_data["alt"])
					key.set_shift(key_data["shift"])
				"nothing":
					key.type = KeyboardKey.TYPE.NOTHING
				"alt":
					key.type = KeyboardKey.TYPE.ALT
					key.set_main(key_data["main"])
					key.toggle_mode = true
					alt_keys.append(key)
				"shift":
					key.type = KeyboardKey.TYPE.SHIFT
					key.set_main(key_data["main"])
					key.toggle_mode = true
					shift_keys.append(key)
				"space":
					key.type = KeyboardKey.TYPE.SPACE
				"enter":
					key.type = KeyboardKey.TYPE.ENTER
					key.set_main(key_data["main"])
				"backspace":
					key.type = KeyboardKey.TYPE.BACKSPACE
					key.set_main(key_data["main"])

			# key size
			var width_factor : int = key_data.get("width_factor", 1)
			key.rect_min_size.x = key_width * width_factor + horizontal_separation * (width_factor - 1)
			key.rect_min_size.y = key_height

			row.add_child(key)
			if not first_key:
				first_key = key
			key.connect("pressed", self, "_on_key_pressed", [key])


################################################################################
## PRIVATE FUNCTIONS
func _update_keys() -> void:
	var mode : int = KeyboardKey.MODE.MAIN
	if alt_pressed:
		mode = KeyboardKey.MODE.ALT
	elif shift_pressed:
		mode = KeyboardKey.MODE.SHIFT
	for key in get_tree().get_nodes_in_group("keyboard_keys"):
		key.set_mode(mode)


################################################################################
## SIGNAL CALLBACKS
func _on_key_pressed(key : KeyboardKey) -> void:
	match key.type:
		KeyboardKey.TYPE.SHIFT:
			shift_pressed = not shift_pressed
			for k in shift_keys:
				k.pressed = shift_pressed
			_update_keys()
		KeyboardKey.TYPE.ALT:
			alt_pressed = not alt_pressed
			for k in alt_keys:
				k.pressed = alt_pressed
			_update_keys()
	emit_signal("key_pressed", key)
