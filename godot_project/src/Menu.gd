# The game's main menu...
extends Control

onready var _menu_tab_container := $MenuTabContainer

func _ready():
	_menu_tab_container.set_current_tab(classMenuTab.TABS.MAIN)
	#AudioEngine.play_music("main_menu")
	AudioEngine.stop_ambient()

