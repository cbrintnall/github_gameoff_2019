extends Node2D

onready var console = get_node("../console")

export (String) var items_path

var items: Dictionary = {}

func _ready():
	console.add_command("items", funcref(self, "print_items_to_console"))
	
	load_items()

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

func print_items_to_console():
	var output = ""

	for item in get_items():
		output += "\n>" + str(item)

	console.print(output)

func get_items():
	return items.keys()
	
func get_item(key: String):
	if key in items:
		return items[key]
		
	return null

func load_items():
	items = get_item_dict(items_path)
