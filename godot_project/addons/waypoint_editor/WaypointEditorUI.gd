tool
extends HBoxContainer

# status
signal new_waypoint_requested
# selection
signal remove_waypoints_requested
signal duplicate_waypoints_requested
signal connect_waypoints_requested
# properties
signal group_name_changed
signal directional_toggled
signal direction_changed

# status
onready var lb_waypoints := $c_status/lb_waypoints
onready var lb_connections := $c_status/lb_connections
onready var b_new := $c_status/b_new
# selection
onready var b_remove := $c_selection/b_remove
onready var b_duplicate := $c_selection/b_duplicate
onready var b_connect := $c_selection/b_connect
# properties
onready var le_group := $c_properties/hb/vb/hb_group/le_group
onready var cb_directional := $c_properties/hb/vb/hb_directional/cb_directional
onready var sb_direction := $c_properties/hb/vb/hb_direction/sb_direction

# when we update elements, sometimes we don't want to emit signals for that element
var signals_enabled := true

func _ready():
	# connect signals
	# status
	b_new.connect("pressed", self, "_on_b_new_pressed")
	# selection
	b_remove.connect("pressed", self, "_on_b_remove_pressed")
	b_duplicate.connect("pressed", self, "_on_b_duplicate_pressed")
	b_connect.connect("pressed", self, "_on_b_connect_pressed")
	# properties
	le_group.connect("text_changed", self, "_on_le_group_text_changed")
	cb_directional.connect("toggled", self, "_on_cb_directional_toggled")
	sb_direction.connect("value_changed", self, "_on_sb_direction_value_changed")

	# disable all
	set_new_enabled(false)
	set_selection_container_enabled(false)
	set_properties_container_enabled(false)
	update_waypoint_count(0, 0)
	update_connection_count(0)
	update_properties_container("", true, 0.0)

func set_new_enabled(v : bool):
	b_new.disabled = not v

func update_selection_container(waypoints_size : int):
	b_remove.disabled = not waypoints_size > 0
	b_duplicate.disabled = not waypoints_size > 0
	b_connect.disabled = not waypoints_size > 1

func update_properties_container(group_name : String, directional : bool, direction : float):
	signals_enabled = false
	le_group.text = group_name
	cb_directional.pressed = directional
	sb_direction.value = direction
	signals_enabled = true

func update_properties_direction_enabled():
	sb_direction.editable = cb_directional.pressed

func set_selection_container_enabled(v : bool):
	b_remove.disabled = not v
	b_duplicate.disabled = not v
	b_connect.disabled = not v

func set_properties_container_enabled(v : bool):
	le_group.editable = v
	cb_directional.disabled = not v
	sb_direction.editable = v

func update_waypoint_count(selected : int, total : int):
	lb_waypoints.text = str(selected) + "/" + str(total) + " waypoint(s) selected"

func update_connection_count(total : int):
	lb_connections.text = str(total) + " connection(s)"

# callbacks

# [status]

func _on_b_new_pressed():
	emit_signal("new_waypoint_requested")

# [selection]

func _on_b_remove_pressed():
	emit_signal("remove_waypoints_requested")

func _on_b_duplicate_pressed():
	emit_signal("duplicate_waypoints_requested")

func _on_b_connect_pressed():
	emit_signal("connect_waypoints_requested")

# [properties]

func _on_le_group_text_changed(value : String):
	if signals_enabled:
		emit_signal("group_name_changed", value)

func _on_cb_directional_toggled(value : bool):
	if signals_enabled:
		emit_signal("directional_toggled", value)

func _on_sb_direction_value_changed(value : float):
	if signals_enabled:
		emit_signal("direction_changed", value)
