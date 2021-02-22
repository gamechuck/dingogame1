class_name classInteractPrompt
extends Node

################################################################################
# PRIVATE VARIABLES

enum INTERACT_TEXT_TYPE { INTERACT, CARRY, DROP, DISPOSE, EXIT }

onready var _interact_prompt := $VB/InteractActionPrompt
onready var _sabotage_prompt := $VB/SabotageActionPrompt

onready var _prompt_data := {
	"control_type": {
		"keyboard": {
			"textures": {
				"interact": preload("res://ndh-assets/UI/elements/f_button.png"),
				"sabotage" : preload("res://ndh-assets/UI/elements/e_button.png"),
			}
		},
		"mouse": {
			# TODO: replace with mouse sprites
			"textures": {
				"interact": preload("res://ndh-assets/UI/elements/f_button.png"),
				"sabotage" : preload("res://ndh-assets/UI/elements/e_button.png"),
			}
		}
	},
	"texts": {
		"interact": {
			INTERACT_TEXT_TYPE.INTERACT: "Interact",
			INTERACT_TEXT_TYPE.CARRY: "Carry",
			INTERACT_TEXT_TYPE.DROP: "Drop",
			INTERACT_TEXT_TYPE.DISPOSE: "Dispose",
			INTERACT_TEXT_TYPE.EXIT: "Exit",
		}
	}
}

################################################################################
# GODOT CALLBACKS
func _ready() -> void:
	ConfigData.connect("input_mode_changed", self, "_on_input_mode_changed")
	_setup_button_textures()
	hide_all()

################################################################################
# PRIVATE FUNCTIONS

func _setup_button_textures() -> void:
	var textures_data : Dictionary
	# This is removed, since all interaction we are doing now is with keyboard
	#if ConfigData.is_using_mouse_input():
	#	textures_data = _prompt_data.get("control_type").get("mouse").get("textures")
	#else:
	textures_data = _prompt_data.get("control_type").get("keyboard").get("textures")
	_interact_prompt.button_texture = textures_data.get("interact")
	_sabotage_prompt.button_texture = textures_data.get("sabotage")

################################################################################
# PUBLIC FUNCTIONS

func hide_all() -> void:
	_interact_prompt.hide()
	_sabotage_prompt.hide()

func show_interact() -> void:
	_interact_prompt.show()

func set_interact_text(text_type := 0) -> void:
	_interact_prompt.text = _prompt_data["texts"]["interact"].get(text_type, "WRONG_INTERACT_TEXT_TYPE")

func show_sabotage() -> void:
	_sabotage_prompt.show()

###############################################################################
# SIGNAL CALLBACKS

func _on_input_mode_changed() -> void:
	_setup_button_textures()
