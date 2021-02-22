tool
extends VBoxContainer

var volume_dict := {
	VOLUME.MASTER: {
		"text": "Master"
	},
	VOLUME.MUSIC: {
		"text": "Music"
	},
	VOLUME.SFX: {
		"text": "SFX"
	},
	VOLUME.AMBIENT_SOUND: {
		"text": "Ambient sound"
	},
}

export(bool) var can_be_muted := true setget set_can_be_muted
func set_can_be_muted(value : bool) -> void:
	can_be_muted = value
	$MuteCheckBox.visible = value

enum VOLUME {MASTER = 0, MUSIC = 1, SFX = 2, AMBIENT_SOUND = 3}
export(VOLUME) var volume_type := VOLUME.MASTER setget set_volume_type
func set_volume_type(value : int):
	volume_type = value
	var volume_settings : Dictionary = volume_dict[value]
	$HBoxContainer/Label.text = volume_settings.text
	$MuteCheckBox.text = "Mute " + volume_settings.text

func _on_check_box_toggled(value : bool):
	match volume_type:
		VOLUME.MASTER:
			ConfigData.mute_master = value
		VOLUME.MUSIC:
			ConfigData.mute_music = value 
		VOLUME.SFX:
			ConfigData.mute_sfx = value
		VOLUME.SFX:
			ConfigData.mute_ambient_sound = value 

func _on_slider_value_changed(value : float):
	$HBoxContainer/VolumeLabel.text = "%3d %%" % value

	match volume_type:
		VOLUME.MASTER:
			ConfigData.master_volume = value 
		VOLUME.MUSIC:
			ConfigData.music_volume = value 
		VOLUME.SFX:
			ConfigData.sfx_volume = value
			#AudioEngine.play_effect("door_open")
		VOLUME.AMBIENT_SOUND:
			ConfigData.ambient_sound_volume = value 

func _ready():
	if not Engine.editor_hint:
		var _error : int = $HBoxContainer/VolumeSlider.connect("value_changed", self, "_on_slider_value_changed")
		_error = $MuteCheckBox.connect("toggled", self, "_on_check_box_toggled")

func update_setting() -> void:
	match volume_type:
		VOLUME.MASTER:
			$HBoxContainer/VolumeSlider.value = ConfigData.master_volume
			$MuteCheckBox.pressed = ConfigData.mute_master
		VOLUME.MUSIC:
			$HBoxContainer/VolumeSlider.value = ConfigData.music_volume
			$MuteCheckBox.pressed = ConfigData.mute_music
		VOLUME.SFX:
			$HBoxContainer/VolumeSlider.value = ConfigData.sfx_volume
			$MuteCheckBox.pressed = ConfigData.mute_sfx
		VOLUME.SFX:
			$HBoxContainer/VolumeSlider.value = ConfigData.ambient_sound_volume
			$MuteCheckBox.pressed = ConfigData.mute_ambient_sound
