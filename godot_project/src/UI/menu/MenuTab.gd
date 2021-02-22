extends Control
class_name classMenuTab

enum TABS {MAIN = 0, SETTINGS = 1, WORLD_MAP = 2, HOW_TO_PLAY = 3}
export(TABS) var tab_type := TABS.MAIN setget set_tab_type
func set_tab_type(value : int):
	tab_type = value

signal button_pressed

func _on_back_button_pressed():
	emit_signal("button_pressed", TABS.MAIN)

func _on_quit_button_pressed():
	Flow.deferred_quit()

func update_tab():
	pass
