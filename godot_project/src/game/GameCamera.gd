extends Camera2D

const SHAKE_DURATION_DEFAULT := 0.5
const SHAKE_DURATION_TAKE_DAMAGE := 0.3
const SHAKE_DURATION_DEAL_DAMAGE := 0.125

const SHAKE_STRENGTH_DEFAULT := 3.0
const SHAKE_STRENGTH_TAKE_DAMAGE := 3.0
const SHAKE_STRENGTH_DEAL_DAMAGE := 3.0

var shake_strength := 2.0
var shake_t := 0.0

var shake_enabled := ConfigData.camera_shake_enabled

func _ready() -> void:
	add_to_group("game_cameras")

func _process(delta) -> void:
	if shake_enabled:
		if shake_t > 0.0:
			shake_t -= delta
			if shake_t <= 0.0:
				offset = Vector2.ZERO
			else:
				offset = Vector2(rand_range(-shake_strength, shake_strength), rand_range(-shake_strength, shake_strength))

func shake(duration := SHAKE_DURATION_DEFAULT, strength := SHAKE_STRENGTH_DEFAULT) -> void:
	if not shake_enabled: return

	shake_t = duration
	shake_strength = strength
