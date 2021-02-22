class_name classCharacterAnimations
extends Node

enum ANIMATION_TYPE {
	NONE, IDLE, WALK, RUN, ATTACK, DEATH, INTERACT, KNOCKED, IDLE_WITH_BODY,
	WALK_WITH_BODY, DROP_BODY, DEATH_INVESTIGATED, WALK_CARRY_WOOD
}

################################################################################
## PLAYER ANIMATIONS

const PLAYER_DEFAULT : Dictionary = {
	Global.DIRECTION.NW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.INTERACT:{
			"animation_name": "use_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_with_body_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_with_body_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.DROP_BODY:{
			"animation_name": "drop_body_ne",
			"flip_h": true
		}
	},
	Global.DIRECTION.N:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_n"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_n"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_n"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_n"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.INTERACT:{
			"animation_name": "use_n"
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_n"
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_with_body_n"
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_with_body_n"
		},
		ANIMATION_TYPE.DROP_BODY:{
			"animation_name": "drop_body_n"
		}
	},
	Global.DIRECTION.NE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_ne"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_ne"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_ne"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_ne"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.INTERACT:{
			"animation_name": "use_ne"
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_ne"
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_with_body_ne"
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_with_body_ne"
		},
		ANIMATION_TYPE.DROP_BODY:{
			"animation_name": "drop_body_ne"
		}
	},
	Global.DIRECTION.E:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_e"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_e"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_e"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_e"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.INTERACT:{
			"animation_name": "use_e"
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_e"
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_with_body_e"
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_with_body_e"
		},
		ANIMATION_TYPE.DROP_BODY:{
			"animation_name": "drop_body_e"
		}
	},
	Global.DIRECTION.SE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_se"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_se"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_se"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_se"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.INTERACT:{
			"animation_name": "use_se"
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_se"
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_with_body_se"
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_with_body_se"
		},
		ANIMATION_TYPE.DROP_BODY:{
			"animation_name": "drop_body_se"
		}
	},
	Global.DIRECTION.S:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_s"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_s"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_s"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_s"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.INTERACT:{
			"animation_name": "use_s"
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_s"
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_with_body_s"
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_with_body_s"
		},
		ANIMATION_TYPE.DROP_BODY:{
			"animation_name": "drop_body_s"
		}
	},
	Global.DIRECTION.SW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_se",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_se",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_se",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_se",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.INTERACT:{
			"animation_name": "use_se",
			"flip_h": true
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_se",
			"flip_h": true
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_with_body_se",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_with_body_se",
			"flip_h": true
		},
		ANIMATION_TYPE.DROP_BODY:{
			"animation_name": "drop_body_se",
			"flip_h": true
		}
	},
	Global.DIRECTION.W:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_e",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_e",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_e",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_e",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.INTERACT:{
			"animation_name": "use_e",
			"flip_h": true
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_e",
			"flip_h": true
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_with_body_e",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_with_body_e",
			"flip_h": true
		},
		ANIMATION_TYPE.DROP_BODY:{
			"animation_name": "drop_body_e",
			"flip_h": true
		}
	},
}

const PLAYER_IN_WHEAT : Dictionary = {
	Global.DIRECTION.NW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_in_wheat_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_in_wheat_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_in_wheat_ne",
			"flip_h": true
		},
	},
	Global.DIRECTION.N:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_in_wheat_n"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_n"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_n"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_n"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_in_wheat_n"
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_in_wheat_n"
		}
	},
	Global.DIRECTION.NE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_in_wheat_ne"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_ne"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_ne"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_ne"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_in_wheat_ne"
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_in_wheat_ne"
		}
	},
	Global.DIRECTION.E:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_in_wheat_e"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_e"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_e"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_e"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_in_wheat_e"
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_in_wheat_e"
		}
	},
	Global.DIRECTION.SE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_in_wheat_se"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_se"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_se"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_se"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_in_wheat_se"
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_in_wheat_se"
		}
	},
	Global.DIRECTION.S:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_in_wheat_s"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_s"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_s"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_s"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_in_wheat_s"
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_in_wheat_s"
		}
	},
	Global.DIRECTION.SW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_in_wheat_se",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_se",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_se",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_se",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_in_wheat_se",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_in_wheat_se",
			"flip_h": true
		}
	},
	Global.DIRECTION.W:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_in_wheat_e",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_e",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_e",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_e",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		},
		ANIMATION_TYPE.IDLE_WITH_BODY:{
			"animation_name": "idle_in_wheat_e",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK_WITH_BODY:{
			"animation_name": "walk_in_wheat_e",
			"flip_h": true
		}
	},
}

################################################################################
## VILLAGER ANIMATIONS

const VILLAGER_DEFAULT : Dictionary = {
	Global.DIRECTION.NW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.DEATH_INVESTIGATED:{
			"animation_name": "death_outline"
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK_CARRY_WOOD:{
			"animation_name": "walk_with_wood_ne",
			"flip_h": true
		}
	},
	Global.DIRECTION.N:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_n"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_n"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_n"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_n"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.DEATH_INVESTIGATED:{
			"animation_name": "death_outline"
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_n"
		},
		ANIMATION_TYPE.WALK_CARRY_WOOD:{
			"animation_name": "walk_with_wood_n"
		}
	},
	Global.DIRECTION.NE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_ne"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_ne"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_ne"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_ne"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.DEATH_INVESTIGATED:{
			"animation_name": "death_outline"
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_ne"
		},
		ANIMATION_TYPE.WALK_CARRY_WOOD:{
			"animation_name": "walk_with_wood_ne"
		}
	},
	Global.DIRECTION.E:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_e"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_e"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_e"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_e"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.DEATH_INVESTIGATED:{
			"animation_name": "death_outline"
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_ne"
		},
		ANIMATION_TYPE.WALK_CARRY_WOOD:{
			"animation_name": "walk_with_wood_ne"
		}
	},
	Global.DIRECTION.SE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_se"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_se"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_se"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_e"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.DEATH_INVESTIGATED:{
			"animation_name": "death_outline"
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_se",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK_CARRY_WOOD:{
			"animation_name": "walk_with_wood_se",
		}
	},
	Global.DIRECTION.S:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_s"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_s"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_s"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_s"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.DEATH_INVESTIGATED:{
			"animation_name": "death_outline"
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_s"
		},
		ANIMATION_TYPE.WALK_CARRY_WOOD:{
			"animation_name": "walk_with_wood_s"
		}
	},
	Global.DIRECTION.SW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_se",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_se",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_se",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_e",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.DEATH_INVESTIGATED:{
			"animation_name": "death_outline"
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_se",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK_CARRY_WOOD:{
			"animation_name": "walk_with_wood_se",
			"flip_h": true
		}
	},
	Global.DIRECTION.W:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_e",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_e",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_e",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_e",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		},
		ANIMATION_TYPE.DEATH_INVESTIGATED:{
			"animation_name": "death_outline"
		},
		ANIMATION_TYPE.KNOCKED:{
			"animation_name": "hurt_e",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK_CARRY_WOOD:{
			"animation_name": "walk_with_wood_e",
			"flip_h": true
		}
	}
}
const VILLAGER_IN_WHEAT : Dictionary = {
	Global.DIRECTION.NW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "walk_in_wheat_e",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_e",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_e",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_e",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.N:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "walk_in_wheat_n"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_n"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_n"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_n"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.NE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "walk_in_wheat_ne"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_ne"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_ne"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_ne"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.E:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "walk_in_wheat_e"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_e"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_e"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_e"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.SE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "walk_in_wheat_se"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_se"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_se"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_se"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.S:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "walk_in_wheat_s"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_s"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_s"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_s"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.SW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "walk_in_wheat_se",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_se",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_se",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_se",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.W:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "walk_in_wheat_e",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_e",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_e",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_e",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
}
const VILLAGER_CARRYING_FORK = {
	Global.DIRECTION.NW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_with_pitchforks_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_with_fork_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_with_fork_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	},
	Global.DIRECTION.N:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_with_pitchforks_n"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_with_fork_n"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_with_fork_n"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_n"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	},
	Global.DIRECTION.NE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_with_pitchforks_ne"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_with_fork_ne"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_with_fork_ne"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_ne"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	},
	Global.DIRECTION.E:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_with_pitchforks_e"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_with_fork_e"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_with_fork_e"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_e"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	},
	Global.DIRECTION.SE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_with_pitchforks_se"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_with_fork_se"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_with_fork_se"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_e"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	},
	Global.DIRECTION.S:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_with_pitchforks_s"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_with_fork_s"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_with_fork_s"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_s"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	},
	Global.DIRECTION.SW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_with_pitchforks_se",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_with_fork_se",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_with_fork_se",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_e",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	},
	Global.DIRECTION.W:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_with_pitchforks_e",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_with_fork_e",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_with_fork_e",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_e",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	}
}
const VILLAGER_CARRY_FORK_IN_WHEAT = {
	Global.DIRECTION.NW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_pitchfork_wheat_e",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_pitchfork_e",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_pitchfork_e",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_with_fork_e",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.N:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_pitchfork_wheat_n"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_pitchfork_n"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_pitchfork_n"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_with_fork_n"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.NE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_pitchfork_wheat_ne"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_pitchfork_ne"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_pitchfork_ne"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_with_fork_ne"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.E:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_pitchfork_wheat_e"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_pitchfork_e"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_pitchfork_e"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_with_fork_e"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.SE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_pitchfork_wheat_se"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_pitchfork_se"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_se"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_with_fork_se"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.S:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_pitchfork_wheat_s"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_pitchfork_s"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_pitchfork_s"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_with_fork_s"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.SW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_pitchfork_wheat_se",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_pitchfork_se",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_pitchfork_se",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_with_fork_se",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.W:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_pitchfork_wheat_e",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_in_wheat_pitchfork_e",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_in_wheat_pitchfork_e",
			"flip_h": true
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_in_wheat_with_fork_e",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
}

################################################################################
## MAYOR ANIMATIONS

const MAYOR_DEFAULT : Dictionary = {
	Global.DIRECTION.NW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	},
	Global.DIRECTION.N:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_n"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_n"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_n"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	},
	Global.DIRECTION.NE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_ne"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_ne"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_ne"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	},
	Global.DIRECTION.E:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_e"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_e"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_e"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	},
	Global.DIRECTION.SE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_se"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_se"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_se"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	},
	Global.DIRECTION.S:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_s"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_s"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_s"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_s"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	},
	Global.DIRECTION.SW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_se",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_se",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_se",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	},
	Global.DIRECTION.W:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_e",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_e",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_e",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_e"
		}
	}
}

const MAYOR_IN_WHEAT : Dictionary = {
	Global.DIRECTION.NW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_ne",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.N:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_n"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_n"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_n"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.NE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_ne"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_ne"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_ne"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.E:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_e"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_e"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_e"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.SE:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_se"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_se"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_se"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.S:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_s"
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_s"
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_s"
		},
		ANIMATION_TYPE.ATTACK:{
			"animation_name": "attack_s"
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.SW:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_se",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_se",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_se",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	},
	Global.DIRECTION.W:{
		ANIMATION_TYPE.IDLE:{
			"animation_name": "idle_e",
			"flip_h": true
		},
		ANIMATION_TYPE.WALK:{
			"animation_name": "walk_e",
			"flip_h": true
		},
		ANIMATION_TYPE.RUN:{
			"animation_name": "run_e",
			"flip_h": true
		},
		ANIMATION_TYPE.DEATH:{
			"animation_name": "death_in_wheat"
		}
	}
}
