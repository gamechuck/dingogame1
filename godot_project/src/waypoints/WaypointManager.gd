tool
class_name classWaypointManager
extends Node2D

const SCENE_WAYPOINT := preload("res://src/waypoints/Waypoint.tscn")

# list of classWaypointConnection resources
export (Array) var _connections := []

# gets built on game start; used for navigation
var astar := AStar2D.new()

################################################################################
## GODOT CALLBACKS

func _ready() -> void:
	# for waypoint id randomization
	randomize()

	# build astar
	# (append waypoints)
	for waypoint in get_children():
		astar.add_point(waypoint.id, waypoint.global_position)
	# (append connections)
	for connection in _connections:
		astar.connect_points(connection.id_a, connection.id_b)

	_cleanup_bad_connections()
	update()
	_update_marks()

func _process(_delta : float) -> void:
	# (constantly updating in editor because we don't know if some things have changed)
	if Engine.editor_hint:
		_cleanup_bad_connections()
		update() # draw waypoint connections
		_update_marks()

func _draw() -> void:
	if visible:
		_draw_connections()

################################################################################
## PUBLIC FUNCTIONS

## CONNECTIONS

func has_connection(id_a, id_b) -> bool:
	var connection_to_check = connection_new(id_a, id_b)

	for connection in _connections:
		if connections_are_equal(connection_to_check, connection):
			return true
	return false

func add_connection(id_a, id_b) -> void:
	var connection = connection_new(id_a, id_b)
	if connection:
		_connections.append(connection)

func remove_connection(id_a, id_b) -> void:
	var connection_to_remove = connection_new(id_a, id_b)

	for connection_idx in _connections.size():
		var connection : classWaypointConnection = _connections[connection_idx]
		if connections_are_equal(connection_to_remove, connection):
			_connections.remove(connection_idx)
			return
	push_error("cannot remove non-existing connection (" + str(id_a) + ", " + str(id_b) + ")")

func toggle_connection(id_a, id_b) -> void:
	if has_connection(id_a, id_b):
		remove_connection(id_a, id_b)
	else:
		add_connection(id_a, id_b)

## WAYPOINTS

func has_waypoint(id : int) -> bool:
	var children : Array = get_children()
	for child in children:
		if child.id == id:
			return true
	return false

func get_waypoint_or_null(id : int) -> Node2D:
	for child in get_children():
		if child.id == id:
			return child
	return null

func add_waypoint() -> classWaypoint:
	var scene := get_tree().edited_scene_root
	var wp = SCENE_WAYPOINT.instance()
	add_child(wp)
	wp._randomize_id()
	wp.set_owner(scene)
	return wp

func duplicate_waypoint(waypoint : classWaypoint) -> void:
	var wp : classWaypoint = add_waypoint()
	wp.set_group_name(waypoint.group_name)
	wp.set_directional(waypoint.directional)
	wp.set_direction(waypoint.direction)
	wp.global_position = waypoint.global_position

func remove_waypoint(id : int) -> void:
	for child in get_children():
		if child.id == id:
			remove_child(child)
			child.queue_free()

			# cleanup connections
			for i in range(_connections.size() - 1, -1, -1):
				var connection : classWaypointConnection = _connections[i]
				if connection_has_id(connection, id):
					_connections.remove(i)
			return

# gets random waypoint from provided group
# it will try get a non-reserved waypoint in the group first
# if all are reserved, returns random from group
# if no group, returns any random waypoint
func get_random_waypoint(group_name := "") -> classWaypoint:
	if get_child_count() == 0:
		push_error("no waypoints exist!")
		return null

	# first get waypoints in cspecified group
	var waypoints_in_group := []
	for waypoint in get_children():
		# skip waypoints with different group_name, if provided
		if group_name != "" and not waypoint.group_name == group_name:
			continue
		waypoints_in_group.append(waypoint)

	# now get non-reserved waypoints
	var non_reserved_waypoints := []
	for waypoint in waypoints_in_group:
		if waypoint.reserved:
			continue
		non_reserved_waypoints.append(waypoint)

	# finally, return random non-reserved waypoint if any
	if non_reserved_waypoints.size() > 0:
		return non_reserved_waypoints[randi() % non_reserved_waypoints.size()]

	# no non-reserved waypoints; return reserved one but in group
	if waypoints_in_group.size() > 0:
		return waypoints_in_group[randi() % waypoints_in_group.size()]

	# no waypoint in group, return any waypoint
	return get_children()[randi() % get_child_count()]

## ASTAR / NAVIGATION

# enable/disable all astar points
func set_points_disabled(value : bool) -> void:
	var points := astar.get_points()
	for point in points:
		astar.set_point_disabled(point, value)

# navigation query; called by Town
func get_path_between_waypoint_ids(id_a : int, id_b : int) -> PoolVector2Array:
	return astar.get_point_path(id_a, id_b)

## CONNECTION CLASS FUNCTIONS
# these are not tied to classWaypointConnection because of certain issues with reloading saved resources
# (data persists when resources are reloaded, but functions don't for some stupid reason, so we have that here)

func connections_are_equal(a : classWaypointConnection, b : classWaypointConnection) -> bool:
	return a.id_a == b.id_a and a.id_b == b.id_b or \
			a.id_a == b.id_b and a.id_b == b.id_a

func connection_has_id(c : classWaypointConnection, id : int) -> bool:
	return c.id_a == id or c.id_b == id

func connection_new(id_a : int, id_b : int) -> classWaypointConnection:
	if id_a == id_b:
		push_error("cannot connect waypoint to itself!")
		return null

	var connection = classWaypointConnection.new()
	if id_b > id_a:
		connection.id_a = id_b
		connection.id_b = id_a
	else:
		connection.id_a = id_a
		connection.id_b = id_b

	return connection

################################################################################
## PRIVATE FUNCTIONS

# non-connected waypoints will turn red, others will turn white
func _update_marks() -> void:
	# first unmark all non-connected waypoints
	for waypoint in get_children():
		waypoint.set_marked(false)

	# now mark connected ones
	for connection in _connections:
		get_waypoint_or_null(connection.id_a).set_marked(true)
		get_waypoint_or_null(connection.id_b).set_marked(true)

# removes connections with non-existing waypoints
func _cleanup_bad_connections() -> void:
	for i in range(_connections.size() - 1, -1, -1):
		var connection : classWaypointConnection = _connections[i]
		if not has_waypoint(connection.id_a) or not has_waypoint(connection.id_b):
			push_warning("cleaned up bad connection " + str(connection.id_a) + "-" + str(connection.id_b) + "!")
			_connections.remove(i)
			continue

func _draw_connections() -> void:
	for i in _connections.size():
		var connection : classWaypointConnection = _connections[i]
		var a : Node2D = get_waypoint_or_null(connection.id_a)
		var b : Node2D = get_waypoint_or_null(connection.id_b)
		if a and b:
			draw_line(a.global_position, b.global_position, Color(0.4, 0.4, 0.4), 1.5)
