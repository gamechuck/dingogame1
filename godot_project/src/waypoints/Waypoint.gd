tool
class_name classWaypoint
extends Sprite

# set by Waypoints manager node
export (int) var id = -1

export(Global.WAYPOINT_REGION) var animation_region := 0

export (bool) var directional = false setget set_directional
func set_directional(v : bool) -> void:
	directional = v
	if $DirectionSprite:
		$DirectionSprite.visible = directional

export (float) var direction = 0.0 setget set_direction
func set_direction(v : float) -> void:
	direction = v
	if $DirectionSprite:
		$DirectionSprite.rotation_degrees = direction

export (String) var group_name = "" setget set_group_name
func set_group_name(v : String) -> void:
	group_name = v
	if $GroupNameLabel:
		$GroupNameLabel.text = v
		$GroupNameLabel.visible = not v.empty()

# when NPC goes to a waypoint, it gets reserved so other NPCs don't go to same one
var reserved := false

# visually distinguish waypoints
# (currently used to distinguish non-connected and connected ones)
var marked := false setget set_marked
func set_marked(v : bool) -> void:
	marked = v

	if marked:
		self_modulate = Color.white
		scale = Vector2.ONE * 0.8
	else:
		self_modulate = Color.orangered
		scale = Vector2.ONE

func _ready() -> void:
	set_directional(directional)
	set_direction(direction)
	set_group_name(group_name)
	set_marked(marked)

# called by waypoints manager node
func _randomize_id() -> void:
	if id == -1:
#		id = randi() % 9223372036854775807 # 2^63 - 1
		id = randi() % 2147483647 # 2^31 - 1
