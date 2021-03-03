extends Node

signal input_provided
signal admin_code_entered
signal key_just_pressed
signal key_just_released

enum KEY { UP, DOWN, LEFT, RIGHT, B0, B1, B2, B3, B4, B5, B6, B7 }

const KEY_TO_INPUT_ACTION := {
	KEY.UP: "up",
	KEY.DOWN: "down",
	KEY.LEFT: "left",
	KEY.RIGHT: "right",
	KEY.B0: "b0",
	KEY.B1: "b1",
	KEY.B2: "b2",
	KEY.B3: "b3",
	KEY.B4: "b4",
	KEY.B5: "b5",
	KEY.B6: "b6",
	KEY.B7: "b7",
}

var kp := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var kr := [9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9]

var blocked := false setget set_blocked
func set_blocked(v : bool) -> void:
	blocked = v

var admin_code_press_count := 0

var block_frame := false

func _process(delta : float) -> void:
	if block_frame:
		block_frame = false

	# update keys
	for key in KEY_TO_INPUT_ACTION.keys():
		if Input.is_action_pressed(KEY_TO_INPUT_ACTION[key]):
			kp[key] += 1
			if kp[key] == 1:
				emit_signal("input_provided")
				emit_signal("key_just_pressed", key)
			kr[key] = 0
		else:
			kp[key] = 0
			kr[key] += 1
			if kr[key] == 1:
				emit_signal("input_provided")
				emit_signal("key_just_released", key)

	# check admin code
	if key_pressed(KEY.LEFT) and key_pressed(KEY.RIGHT):
		if key_just_pressed(KEY.UP):
			admin_code_press_count += 1
			if admin_code_press_count == 3:
				emit_signal("admin_code_entered")
	else:
		admin_code_press_count = 0

	# update controller display
	#DebugOverlay.update_controller_display(kp)

func key_pressed(key : int) -> bool:
	assert(key >= 0 and key < kp.size())
	return is_free() and kp[key] > 0

func key_just_pressed(key : int) -> bool:
	assert(key >= 0 and key < kp.size())
	return is_free() and kp[key] == 1

func key_released(key : int) -> bool:
	assert(key >= 0 and key < kp.size())
	return is_free() and kr[key] > 0

func key_just_released(key : int) -> bool:
	assert(key >= 0 and key < kp.size())
	return is_free() and kr[key] == 1

# call to see if Controller is free for use
# it's set to false if blocked is set to true, or block_frame is enabled,
# or Keyboard is visible
func is_free() -> bool:
	return not (blocked or block_frame or Keyboard.visible)

func get_button_index(key : int) -> int:
	if 4 <= key and key <= 11:
		return key - 4
	else:
		return -1

func release_all_inputs() -> void:
	for i in kr.size():
		kr[i] = 99
