tool
extends EditorPlugin

const SCENE_WAYPOINT_EDITOR_UI := preload("res://addons/waypoint_editor/WaypointEditorUI.tscn")

var editor_selection : EditorSelection = get_editor_interface().get_selection()

var dock : Control
var dock_enabled := false

var waypoint_count_total := 0

# selected waypoints
var waypoints := []

# Waypoints node in the scene (if it exists)
var waypoint_container : Node2D

# godot callbacks

func _enter_tree():
	editor_selection.connect("selection_changed", self, "_on_editor_selection_changed")

	dock = SCENE_WAYPOINT_EDITOR_UI.instance()
	# [status]
	dock.connect("new_waypoint_requested", self, "_on_new_waypoint_requested")
	# [selection]
	dock.connect("remove_waypoints_requested", self, "_on_remove_waypoints_requested")
	dock.connect("duplicate_waypoints_requested", self, "_on_duplicate_waypoints_requested")
	dock.connect("connect_waypoints_requested", self, "_on_connect_waypoints_requested")
	# [properties]
	dock.connect("group_name_changed", self, "_on_group_name_changed")
	dock.connect("directional_toggled", self, "_on_directional_toggled")
	dock.connect("direction_changed", self, "_on_direction_changed")

	_fetch_waypoint_container()
	_update_waypoint_count()
	_update_panel()

	print("WaypointEditor plugin started!")

func _exit_tree():
	_disable_dock()
	dock.free()

	print("WaypointEditor plugin ended!")

func _process(delta):
	# updated every frame so we know if this node exists or not, and show/hide the dock accordingly
	_fetch_waypoint_container()

	_update_waypoint_count()

# functions

func _enable_dock():
	if dock_enabled:
		return

	add_control_to_bottom_panel(dock, "WaypointEditor")
#	make_bottom_panel_item_visible(dock)
	dock_enabled = true

func _disable_dock():
	if not dock_enabled:
		return

	remove_control_from_bottom_panel(dock)
	hide_bottom_panel()
	dock_enabled = false

func _update_panel():
	if not waypoint_container:
		return

	# if we don't have any waypoints, enable making new one
	dock.set_new_enabled(waypoint_count_total == 0)

	dock.update_selection_container(waypoints.size())
	dock.update_connection_count(waypoint_container._connections.size())

	# update properties
	if waypoints.size() > 0:
		dock.set_properties_container_enabled(true)
		var wp : classWaypoint = waypoints[0]
		dock.update_properties_container(wp.group_name, wp.directional, wp.direction)
		dock.update_properties_direction_enabled()
	else:
		dock.set_properties_container_enabled(false)

func _update_waypoint_count():
	var count := get_tree().get_nodes_in_group("waypoint").size()
	if waypoint_count_total != count:
		waypoint_count_total = count
		if dock_enabled:
			dock.update_waypoint_count(waypoints.size(), waypoint_count_total)

func _fetch_waypoint_container():
	waypoint_container = null
	var waypoint_container_nodes = get_tree().get_nodes_in_group("waypoint_container")
	if waypoint_container_nodes.size() > 0:
		waypoint_container = waypoint_container_nodes[0]
	#
	if waypoint_container:
		_enable_dock()
	else:
		_disable_dock()

# signal callbacks

func _on_editor_selection_changed():
	var selected_nodes : Array = editor_selection.get_selected_nodes()

#	_fetch_waypoint_container()

	# filter out waypoints and/or waypoint_container node
	waypoints.clear()
	for w in selected_nodes:
		if w.is_in_group("waypoint"):
			waypoints.append(w)

	if dock_enabled:
		_update_panel()
		dock.update_waypoint_count(waypoints.size(), waypoint_count_total)

# signal callbacks / dock

# [status]

func _on_new_waypoint_requested():
	if not waypoint_container:
		return

	waypoint_container.add_waypoint()

	_update_waypoint_count()
	_update_panel()

# [selection]

func _on_remove_waypoints_requested():
	if not waypoint_container:
		return

	for waypoint in waypoints:
		waypoint_container.remove_waypoint(waypoint.id)

	_update_panel()

func _on_duplicate_waypoints_requested():
	if not waypoint_container or waypoints.size() == 0:
		return

	for waypoint in waypoints:
		waypoint_container.duplicate_waypoint(waypoint)

	_update_waypoint_count()
	_update_panel()

func _on_connect_waypoints_requested():
	if not waypoint_container or waypoints.size() < 2:
		return

	for i in range(0, waypoints.size() - 1):
		for j in range(i + 1, waypoints.size()):
			waypoint_container.toggle_connection(waypoints[i].id, waypoints[j].id)

	_update_panel()

# [properties]

func _on_group_name_changed(value : String):
	if not waypoint_container:
		return

	for waypoint in waypoints:
		waypoint.group_name = value

func _on_directional_toggled(value : bool):
	if not waypoint_container:
		return

	for waypoint in waypoints:
		waypoint.directional = value

	_update_panel()

func _on_direction_changed(value : float):
	if not waypoint_container:
		return

	for waypoint in waypoints:
		waypoint.set_direction(value)
