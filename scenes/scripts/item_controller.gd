extends Node2D

onready var item_map = get_node("items")
onready var placed_items = get_node("placed_items")
onready var console = get_node("../console")

export (String) var items_path

var items: Dictionary = {}
var selected: String = "conveyor_belt"
var current_rotation: int = 0
var last_rotation: int = 0
var selected_texture: int = -1

var groups: Array = []
var path_scene = preload("res://scenes/path.tscn")
var path = path_scene.instance()

# arrow's texture in atlas
var arrow_index = 6

func _ready():
	console.add_command("items", funcref(self, "print_items_to_console"))
	
	load_items()
	selected_texture = get_texture_from_item(selected, "game")

	# Set the hover layer to half opacity, so you can see it easier
	item_map.modulate = Color(item_map.modulate.r, item_map.modulate.g, item_map.modulate.b, 0.5)

func _draw():
	for group in groups:
		var longest_ids: Array = find_furthest_points(group)
		var start: int = longest_ids[0]
		var end: int = longest_ids[1]
		var path: PoolVector3Array = group.get_point_path(start, end)

		for i in range(1, len(path)):
			var current_point = Vector2(path[i].x, path[i].y)
			var last_point = Vector2(path[i-1].x, path[i-1].y)

			draw_line(
				last_point * placed_items.cell_size,
				current_point * placed_items.cell_size,
				Color(255, 0, 0, 255),
				5.0
			)

func _process(delta):
	update()

	var position = get_global_mouse_position()
	var posX = floor(position.x / item_map.cell_size.x)
	var posY = floor(position.y / item_map.cell_size.y)

	if Input.is_action_just_pressed("rotate_item"):
		rotate_item()

	if Input.is_action_just_pressed("left_click"):
		place_item_at(posX, posY, current_rotation)

	if Input.is_action_just_pressed("right_click"):
		remove_item_at(posX, posY)

	if (item_map.get_cell(posX, posY) != selected_texture) || (current_rotation != last_rotation):
		item_map.clear()

		# Sets the current cell
		place_hovered_item(posX, posY, current_rotation)
		place_arrow(posX, posY, current_rotation)

	last_rotation = current_rotation

func is_within(x: int, y: int, range_of: int, tile: int = -1) -> bool:
	for i in range(x, x + range_of):
		if placed_items.get_cell(i, y) != -1:
			return true

	for i in range(x - range_of, x):
		if placed_items.get_cell(i, y) != -1:
			return true

	for i in range(y, y + range_of):
		if placed_items.get_cell(x, i) != -1:
			return true

	for i in range(y - range_of, y):
		if placed_items.get_cell(x, i) != -1:
			return true

	return false

func add_point_to_groups(x: int, y: int):
	# Two scenarios, there is a tile next to this one, in which we add this point to that astar group
	# otherwise, we create a new astar group
	var loc_vec = Vector3(x, y, 0) + Vector3(.5, .5, 0)
	var last_added = null
	var last_added_index: int = -1
	# just to keep track of current position
	var counter: int = -1
	var occupied: bool = false
	var groups_changed: Array = []

	for group in groups:
		counter += 1

		var closest = group.get_closest_point(loc_vec)
		var distance = group.get_point_position(closest).distance_to(loc_vec)

		if distance == 0:
			occupied = true
			break

		# not sure why, but distance function evaluates to 1 if it's a tile away
		if distance <= 1:
			if last_added != null:
				# Need to merge the astar groups
				var points = last_added.get_points()

				# Move all the points from the old graph to the new one
				for point in points:
					var loc = last_added.get_point_position(point)
					group.add_point(group.get_available_point_id(), loc)

				# Remove the old graph from list
				groups.remove(last_added_index)
			
			group.add_point(group.get_available_point_id(), loc_vec)
			last_added = group
			last_added_index = counter
			groups_changed.append(counter)

			# Disconnect all points
			disconnect_all_points(group)

			# Reconnect all points
			connect_points_in_path(group)
			
			print(group.get_points().size())

	if last_added == null && !occupied:
		var new_group = AStar.new()
		new_group.add_point(new_group.get_available_point_id(), loc_vec)
		groups.append(new_group)

func find_furthest_points(graph: AStar) -> Array:
	var distance: int = 0
	var values: Array = [-1, -1]

	var points = graph.get_points()

	for pt1 in points:
		var d1 = graph.get_point_position(pt1)
		for pt2 in points:
			var d2 = graph.get_point_position(pt2)
			if d1.distance_to(d2) > distance:
				values[0] = pt1
				values[1] = pt2

	return values

func disconnect_all_points(graph: AStar) -> void:
	for pt in graph.get_points():
		for cPt in graph.get_point_connections(pt):
			graph.disconnect_points(pt, cPt)

func connect_points_in_path(graph: AStar) -> void:
	var points = graph.get_points()
	for i in range(1, len(points)):
		var last_point = points[i-1]
		var point = points[i]

		graph.connect_points(last_point, point)

func place_hovered_item(x: int, y: int, rotation: int):
	item_map.set_cell(x, y, selected_texture, false, false, is_transposed(rotation))

func place_arrow(x: int, y: int, rotation: int):
	var rotated = !is_transposed(rotation)

	match rotation:
		0:
			item_map.set_cell(x+1, y, arrow_index, true, false, rotated)
		90:
			item_map.set_cell(x, y-1, arrow_index, false, false, rotated)
		180:
			item_map.set_cell(x-1, y, arrow_index, false, false, rotated)
		270:
			item_map.set_cell(x, y+1, arrow_index, false, true, rotated)

func is_transposed(rotation: int):
	return rotation == 90 || rotation == 270

func remove_item_at(x: int, y: int):
	placed_items.set_cell(x, y, -1)

func place_item_at(x: int, y: int, rotation: int):
	# TODO: add next line back in
	#placed_items.set_cell(x, y, selected_texture, false, false, is_transposed(rotation))
	add_point_to_groups(x, y)

func rotate_item():
	current_rotation += 90
	current_rotation %= 360

func get_item_dict(path: String):
	var file = File.new()
	file.open(path, File.READ)
	var contents = file.get_as_text()
	var result = JSON.parse(contents)
	file.close()
	
	if result.error == OK:
		return result.result
	else:
		print("Failed to parse item definition!")

func get_texture_from_item(item: String, texture_type: String):
	var item_def = self.get_item(item)

	if item_def == null:
		return

	var field: String = ""

	if texture_type == "game":
		field = "game_texture"

	if texture_type == "icon":
		field = "icon_texture"

	var fields = item_def[field]

	return fields["tileset_index"]

func print_items_to_console():
	var output = ""

	for item in get_items():
		output += "\n> " + str(item)

	console.print(output)

func get_items():
	return items.keys()
	
func get_item(key: String):
	if key in items:
		return items[key]
		
	return null

func load_items():
	items = get_item_dict(items_path)
