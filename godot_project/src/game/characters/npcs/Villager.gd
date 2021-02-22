class_name classVillager
extends classNPC

var _carrying_fork_animations := {}
var _carrying_fork_in_wheat_animations := {}

func _init() -> void:
	type = "villager"

func _ready() -> void:
	add_to_group("villagers")

	set_hp_max(ConfigData.VILLAGER_HP_MAX)
	set_hp(hp_max)

	attack_power = ConfigData.VILLAGER_ATTACK_POWER
	_run_movement_speed = ConfigData.NPC_RUN_SPEED
	# setup animations
	_default_animations = classCharacterAnimations.VILLAGER_DEFAULT
	_in_wheat_animations = classCharacterAnimations.VILLAGER_IN_WHEAT
	_carrying_fork_animations = classCharacterAnimations.VILLAGER_CARRYING_FORK
	_carrying_fork_in_wheat_animations = classCharacterAnimations.VILLAGER_CARRY_FORK_IN_WHEAT

func _physics_process(_delta):
	if alive:
		if _can_update_animations and not _is_knocked_back:
			_update_animation_state()

func _update_animation_dict() -> void:
	if not is_in_wheat and not has_item() and _last_animation_dict != _default_animations:
		_last_animation_dict = _default_animations
	elif is_in_wheat and not has_item() and _last_animation_dict != _in_wheat_animations:
		_last_animation_dict = _in_wheat_animations
	elif is_in_wheat and has_item() and _last_animation_dict != _carrying_fork_in_wheat_animations:
		_last_animation_dict = _carrying_fork_in_wheat_animations
	elif not is_in_wheat and has_item() and _last_animation_dict != _carrying_fork_animations:
		_last_animation_dict = _carrying_fork_animations
