extends Node

var _effect_players := []

func add_effect():
	var effect_player := AudioStreamPlayer.new()
	add_child(effect_player)

	effect_player.bus = "SFX"
	_effect_players.append(effect_player)

func reset():
	for player in _effect_players:
		player.stop()
		player.stream = null

func play_effect(audio_stream: AudioStream):
	for player in _effect_players:
		if not player.playing:
			player.stream = audio_stream
			player.play()
			return
