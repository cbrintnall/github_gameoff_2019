extends Node2D

onready var map = get_node("tiles")
onready var cam = get_node("Camera2D")

var current_height = 3
var current_width = 3

var WALL = 0
var FLOOR = 1

func _ready():
	create_current_size()
	
func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		expand_room(1)
		
	if Input.is_action_just_pressed("ui_left"):
		expand_room(-1)

func place_floors():
	for i in range(current_height):
		for j in range(current_width):
			map.set_cell(i, j, FLOOR)
	
func place_walls():
	var walls = [-1, current_height, current_width]
	for i in range(-1, current_height+1):
		for j in range(-1, current_width+1):
			if j in walls or i in walls:
				map.set_cell(i, j, WALL)

func set_camera_bounds():
	cam.limit_right = current_width * map.cell_size.x
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_bottom = current_height * map.cell_size.y

func set_camera_to_center():
	var point = Vector2(
		(current_width * map.cell_size.x) / 2,
		(current_height * map.cell_size.y) / 2
	)

	cam.look_at(point)

func create_current_size():
	map.clear()

	place_floors()
	place_walls()
	
func expand_room(by):
	current_height += by
	current_width += by
	
	create_current_size()
	set_camera_to_center()
