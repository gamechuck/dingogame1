extends StaticBody2D
var _default_animations : Dictionary = {
	Global.DIRECTION.E:{
		"animation_name": "track_e",
		"flip_h": false,
		"flip_v": false
	},
	Global.DIRECTION.SE:{
		"animation_name": "track_se",
		"flip_h": false,
		"flip_v": false
	},
	Global.DIRECTION.S:{
		"animation_name": "track_n",
		"flip_h": false,
		"flip_v": true
	},
	Global.DIRECTION.SW:{
		"animation_name": "track_se",
		"flip_h": true,
		"flip_v": false
	},
	Global.DIRECTION.W:{
		"animation_name": "track_e",
		"flip_h": true,
		"flip_v": false
	},
	Global.DIRECTION.NW:{
		"animation_name": "track_ne",
		"flip_h": true,
		"flip_v": false
	},
	Global.DIRECTION.N:{
		"animation_name": "track_n",
		"flip_h": false,
		"flip_v": false
	},
	Global.DIRECTION.NE:{
		"animation_name": "track_ne",
		"flip_h": false,
		"flip_v": false
	},
}

func _ready():
	$Timer.connect("timeout", self, "_on_timeout")
	$Timer.wait_time = ConfigData.PLAYER_TRACKS_DURATION

func _on_timeout() -> void:
	queue_free()

func set_direction(value : int) -> void:
	var state_settings : Dictionary = {}
	state_settings = _default_animations.get(value, {})

	$AnimatedSprite.play(state_settings["animation_name"])
	$AnimatedSprite.flip_h = state_settings["flip_h"]
	$AnimatedSprite.flip_v = state_settings["flip_v"]
