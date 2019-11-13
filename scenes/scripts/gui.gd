extends RichTextLabel

func _ready():
	get_node("../../map_controller").connect("map_changed", self, "_on_map_changed")

func _on_map_changed(controller, x, y):
	self.text = "Round: " + str(controller.current_round)
