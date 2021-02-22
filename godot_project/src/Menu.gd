# The game's main menu...
extends Control

onready var _menu_tab_container := $MenuTabContainer

func _ready():
	# Skip this menu if requested by the default_options.cfg!
	if ConfigData.skip_menu and Flow._game_state == Flow.STATE.STARTUP:
		if ConfigData.verbose_mode : print("Automatically skipping menu as requested by configuration data...")
		Flow.change_scene_to("game")
	else:
		_menu_tab_container.set_current_tab(classMenuTab.TABS.MAIN)
		AudioEngine.play_music("main_menu")
		AudioEngine.stop_ambient()

	Input.set_custom_mouse_cursor(Flow.CURSOR_TEXTURE, Input.CURSOR_ARROW)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed():
			Input.set_custom_mouse_cursor(Flow.CURSOR_PRESSED_TEXTURE, Input.CURSOR_ARROW)
		else:
			Input.set_custom_mouse_cursor(Flow.CURSOR_TEXTURE, Input.CURSOR_ARROW)
