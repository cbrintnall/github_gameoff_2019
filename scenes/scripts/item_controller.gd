extends Node2D

onready var item_map = get_node("items")
onready var placed_items = get_node("placed_items")
onready var console = get_node("../console")
onready var place_checker = $Area2D
onready var place_collider = $Area2D/CollisionShape2D
onready var bad_place = $AudioStreamPlayer2D

export (String) var items_path

var moving_items: Array = [preload("res://scenes/items/egg.tscn")]
var items: Dictionary = {}
var selected: String = "conveyor_belt"
var current_rotation: int = 0
var last_rotation: int = 0
var selected_texture: int = -1
var can_place = false

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
	
	# Set area checking collider to correct size
	place_collider.shape.set_extents(Vector2(item_map.cell_size.x, item_map.cell_size.y) / 2)

func _process(delta):
	# Set collision area for "placeable" checker
	var position = get_global_mouse_position()
	place_checker.position = position
	item_map.align_to_grid(place_checker)
	
	check_if_can_place()
	
	if !can_place:
		item_map.modulate = Color(0.5, 0.0, 0.0, 0.5)
	else:
		item_map.modulate = Color(0, 0.5, 0.0, 0.75)
	
	var pos = item_map.get_tile_coords(position)

	if Input.is_action_just_pressed("rotate_item"):
		rotate_item()
		
	if Input.is_action_just_pressed("left_click"):
		if can_place:
			place_item_at(pos.x, pos.y, current_rotation)
		else:
			bad_place.play(0.0)

	# Move the hovered item if necessary
	if (item_map.get_cell(pos.x, pos.y) != selected_texture) || (current_rotation != last_rotation):
		item_map.clear()

		# Sets the current cell
		place_hovered_item(pos.x, pos.y, current_rotation)
		place_arrow(pos.x, pos.y, current_rotation)

	last_rotation = current_rotation
	
func check_if_can_place():
	var areas = self.place_checker.get_overlapping_areas()
	
	for area in areas:
		if area.is_in_group("placeable_area"):
			can_place = true
			return
			
	can_place = false

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

func place_item_at(x: int, y: int, rotation: int):
	if items[selected].scene == null:
		return

	var instance = items[selected].scene.instance()
	instance.rotation_degrees = current_rotation
	placed_items.place_at_tile(x, y, instance)
	add_child(instance)

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

func get_scene_from_item(item: String):
	return items[item].scene

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

	# Replace the scenes with their loaded counter parts
	for item in items:
		items[item].scene = load(items[item].scene)
