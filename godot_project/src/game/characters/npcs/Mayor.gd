class_name classMayor
extends classNPC

func _init() -> void:
	type = "mayor"

func _ready() -> void:
	add_to_group("mayors")

	set_hp_max(ConfigData.MAYOR_HP_MAX)
	set_hp(hp_max)

	show_alertness_icon = false

	_default_animations = classCharacterAnimations.MAYOR_DEFAULT
	_in_wheat_animations = classCharacterAnimations.MAYOR_IN_WHEAT
	_run_movement_speed = ConfigData.MAYOR_RUN_SPEED

func _physics_process(_delta):
	if alive:
		if _can_update_animations and not _is_knocked_back:
			_update_animation_state()
