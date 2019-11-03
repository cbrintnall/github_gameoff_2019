extends Node2D

onready var item_map = get_node("items")
onready var console = get_node("../console")

export (String) var items_path

var items: Dictionary = {}
var selected: String = "conveyor_belt"
var selected_texture: int = -1
var lastX = -1
var lastY = -1

func _ready():
	console.add_command("items", funcref(self, "print_items_to_console"))
	
	load_items()
	selected_texture = get_texture_from_item(selected, "game")

func _process(delta):
	var position = get_global_mouse_position()
	var posX = floor(position.x / item_map.cell_size.x)
	var posY = floor(position.y / item_map.cell_size.y)

	if item_map.get_cell(posX, posY) != selected_texture:
		# Sets the current cell
		item_map.set_cell(posX, posY, selected_texture)

		# Clears the last cell
		item_map.set_cell(lastX, lastY, -1)

	lastX = posX
	lastY = posY

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
