extends Camera2D

onready var map_control = get_node("../map_controller")

var speed: float = 5.0
var zoom_speed : float = 1.0

func _ready():
	map_control.connect("map_changed", self, "on_map_size_changed")
		
func zoom(amt: float) -> void:
	self.zoom.x += amt
	
func _physics_process(delta):
	if Input.is_action_pressed("zoom_out"):
		zoom(-zoom_speed)
	
	if Input.is_action_pressed("zoom_in"):
		zoom(zoom_speed)
		
	if Input.is_action_pressed("camera_down"):
		self.position.y += speed
		
	if Input.is_action_pressed("camera_left"):
		self.position.x -= speed
		
	if Input.is_action_pressed("camera_right"):
		self.position.x += speed
		
	if Input.is_action_pressed("camera_up"):
		self.position.y -= speed
	
func on_map_size_changed(controller, width, height):
	var point = controller.get_map_size() / 2
	self.position = point
