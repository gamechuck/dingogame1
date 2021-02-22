extends Navigation2D

onready var _nav_map := $NavMap

var _polygons := []
var _holes := []

func _ready() -> void:
	_make_polygons_from_navmap()
	_merge_polygons()
	_append_polygons_to_navigation()
	update()

func _draw() -> void:
	if visible:
		for polygon in _polygons:
			draw_polygon(polygon, [Color(0.1, 1.0, 0.1, 0.5)])
		for hole in _holes:
			draw_polygon(hole, [Color(1.0, 0.1, 0.1, 0.5)])

func _make_polygons_from_navmap() -> void:
	var used_rect : Rect2 = _nav_map.get_used_rect()
	var t_top_left := Vector2.INF
	var t_bot_right := Vector2.INF
	for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
		for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
			if _nav_map.get_cell(x, y) == 1:
				# found nav tile; scan towards right
				if t_top_left == Vector2.INF:
					# start scanning
					t_top_left = Vector2(x, y)
				else:
					# continue scanning
					t_bot_right = Vector2(x, y)
				# mark cell as scanned
				_nav_map.set_cell(x, y, 0)
			else:
				# no nav tile
				if t_top_left != Vector2.INF:
					# something is scanned
					if t_bot_right == Vector2.INF:
						# finish scanning if it just started
						t_bot_right = t_top_left

					# try extend downwards
					var extending := true
					var y2 = t_bot_right.y + 1
					while extending:
						if y2 >= used_rect.position.y + used_rect.size.y:
							# no more room; break
							extending = false
							break
						for x2 in range(t_top_left.x, t_bot_right.x + 1):
							if _nav_map.get_cell(x2, y2) == 1:
								# found nav tile; all good
								pass
							else:
								# no nav tile; break
								extending = false
								break
						if not extending:
							# didn't find nav tile; break
							break
						# if we're here, it means next row is all nav tiles!
						# mark next row as done
						for x2 in range(t_top_left.x, t_bot_right.x + 1):
							_nav_map.set_cell(x2, y2, 0)
						# extend z and pos_bot_right
						y2 += 1
						t_bot_right.y += 1

					# merge tiles into polygon
					var pos_top_left = _nav_map.map_to_world(t_top_left)
					var pos_bot_right = _nav_map.map_to_world(t_bot_right + Vector2.ONE)
					var polygon : PoolVector2Array = [
						Vector2(pos_top_left.x, pos_top_left.y),
						Vector2(pos_bot_right.x, pos_top_left.y),
						Vector2(pos_bot_right.x, pos_bot_right.y),
						Vector2(pos_top_left.x, pos_bot_right.y)
					]
					_polygons.append(polygon)

					t_top_left = Vector2.INF
					t_bot_right = Vector2.INF

func _merge_polygons() -> void:
	if _polygons.size() == 0:
		push_error("POLYGONS SIZE IS 0!")
		return
	elif _polygons.size() == 1:
		push_warning("there's only 1 polygon, no need to merge")
		return

	var merged := true
	while merged == true:
		merged = false

		for i in range(1, _polygons.size()):
			var a : PoolVector2Array = _polygons[i]
			for j in range(0, i):
				var b : PoolVector2Array = _polygons[j]

				var merge_result : Array = Geometry.merge_polygons_2d(a, b)
				if _merge_result_has_more_shapes(merge_result):
					continue
				else:
					# merge suceeded!
					merged = true
					# extract _holes
					for k in range(merge_result.size() - 1, -1, -1):
						if Geometry.is_polygon_clockwise(merge_result[k]):
							_holes.append(merge_result[k])
							merge_result.remove(k)
					# result should have single polygon left
					if merge_result.size() != 1:
						push_error("!")
						return
					_polygons[i] = merge_result[0]
					_polygons.remove(j)
					break
			if merged:
				break

func _append_polygons_to_navigation() -> void:
	var np := NavigationPolygon.new()

	# add polygons
	for polygon in _polygons:
		np.add_outline(polygon)

	# add holes
	for hole in _holes:
		np.add_outline(hole)

	np.make_polygons_from_outlines()
	navpoly_add(np, Transform2D())

# small helper function
func _merge_result_has_more_shapes(result : Array) -> bool:
	var n := 0
	for polygon in result:
		if not Geometry.is_polygon_clockwise(polygon):
			n += 1
			if n > 1:
				return true
	return false
