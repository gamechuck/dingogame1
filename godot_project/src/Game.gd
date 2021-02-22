extends Control

const DIRECTION_TO_CURSOR_TEXTURE := {
	Global.DIRECTION.E: preload("res://ndh-assets/UI/elements/cursor_e.png"),
	Global.DIRECTION.SE: preload("res://ndh-assets/UI/elements/cursor_se.png"),
	Global.DIRECTION.S: preload("res://ndh-assets/UI/elements/cursor_s.png"),
	Global.DIRECTION.SW: preload("res://ndh-assets/UI/elements/cursor_sw.png"),
	Global.DIRECTION.W: preload("res://ndh-assets/UI/elements/cursor_w.png"),
	Global.DIRECTION.NW: preload("res://ndh-assets/UI/elements/cursor_nw.png"),
	Global.DIRECTION.N: preload("res://ndh-assets/UI/elements/cursor_n.png"),
	Global.DIRECTION.NE: preload("res://ndh-assets/UI/elements/cursor_ne.png")
}

#onready var _editor_camera := $EditorCamera
onready var _debug_overlay := $UI/DebugOverlay

var _game_camera : Camera2D
#var _spectator_camera : Camera2D

var _update_cursor := false

func _ready():
	randomize()

	if ConfigData.is_using_keyboard_input():
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		_update_cursor = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_update_cursor = true

	spawn_town()

	AudioEngine.play_music("town_idle")
	AudioEngine.play_ambient("night_ambient")

#	_editor_camera.current = Flow.is_in_editor_mode
#	_game_camera.current = not Flow.is_in_editor_mode

	State.connect("game_state_changed", self, "_on_game_state_changed")

	# apply debug settings
	_debug_overlay.visible = ConfigData.DEBUG_ENABLED and ConfigData.DEBUG_SHOW_DEBUG_OVERLAY

#func _input(event: InputEvent) -> void:
#	if event.is_action_pressed("toggle_editor_mode"):
#		Flow.is_in_editor_mode = not Flow.is_in_editor_mode
#		update_current_camera()
#		get_tree().set_input_as_handled()

#func _process(_delta):
#	if State.loaded_town:
#		var player : classPlayer = State.loaded_town.get_player()
#		if player and _update_cursor:
#			var player_to_mouse_angle := (get_global_mouse_position() - player.global_position).angle()
#			var player_to_mouse_direction : int = Flow.angle_to_direction(fposmod(player_to_mouse_angle, TAU))
#			Input.set_custom_mouse_cursor(DIRECTION_TO_CURSOR_TEXTURE[player_to_mouse_direction], Input.CURSOR_ARROW)

func spawn_town() -> void:
	# Clean up the cases in the State!
	# Why here? Because this needs to be called BEFORE the DebugOverlay starts!
#	State.reset_town_state()

	for child in $ViewportContainer.get_children():
		if child is classTown:
			$ViewportContainer.remove_child(child)
			child.queue_free()

	var town_scene = load("Town").instance()
	$ViewportContainer.add_child(town_scene)
	#TODO: Not sure if best way, but it works so: meh
	_game_camera = town_scene.get_player().get_camera()

#func update_current_camera() -> void:
#	if Flow.is_in_editor_mode:
##		_editor_camera.current = true
#	else:
#		_game_camera.current = true

func _on_game_state_changed(game_state : int) -> void:
	#$ViewportContainer/UI/PlayerOverlay.hide()
	_update_cursor = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(DIRECTION_TO_CURSOR_TEXTURE[Global.DIRECTION.NW], Input.CURSOR_ARROW)
	match game_state:
		State.GAME_STATE.WIN:
			$UI/GameOverlay.show_end_overlay(State.GAME_STATE.WIN)
		State.GAME_STATE.LOSE:
			$UI/GameOverlay.show_end_overlay(State.GAME_STATE.LOSE)
