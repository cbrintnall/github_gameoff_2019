extends Camera2D

onready var map_control = get_node("../map_controller")

func _ready():
	map_control.connect("map_changed", self, "on_map_size_changed")
	
func on_map_size_changed(controller, width, height):
	var point = controller.get_map_size() / 2
	self.position = point
	self.zoom = Vector2(self.zoom.x+.1, self.zoom.y+.1)
