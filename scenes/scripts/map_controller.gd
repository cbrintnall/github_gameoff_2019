extends Node2D

signal map_changed
signal generator_placed

onready var map = $tiles
onready var cam = $Camera2D

var place_floor = preload("res://scenes/placeable_floor.tscn")
var no_place_floor = preload("res://scenes/unplaceable_floor.tscn")
var consumer = preload("res://scenes/consumer.tscn")
var producer = preload("res://scenes/producer.tscn")

var noise = OpenSimplexNoise.new()

var current_round: int = 1
var current_height = 10
var current_width = 10
var rate = 3

var WALL = 0
var FLOOR = 1

func _ready():
	noise.seed = 1234567
	noise.octaves = 4
	noise.period = 1.0
	noise.persistence = 0.8

	expand_room(0)
	
func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		expand_room(rate)
		
	if Input.is_action_just_pressed("ui_left"):
		expand_room(-rate)

func place_floors():
	for i in range(current_height):
		for j in range(current_width):
			var instance = null
			var rng = RandomNumberGenerator.new()
			rng.randomize()
			noise.seed = rng.randi_range(0, 1000000000)
			
			if noise.get_noise_2d(i, j) < 0.1:
				instance = place_floor.instance()
			else:
				instance = no_place_floor.instance()
			
			map.place_at_tile(i, j, instance)
	
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

func get_center_of_map() -> Vector2:
	return Vector2(
		(current_width * map.cell_size.x) / 2,
		(current_height * map.cell_size.y) / 2
	);

func create_current_size():
	current_round += 1

	map.clear()

	place_floors()
	place_walls()
	
func rand_coords() -> Vector2:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return Vector2(rng.randf_range(1, current_width), rng.randf_range(1, current_height))
	
func rand_wall_coords() -> Vector2:
	var final_vector: Vector2 = Vector2.ZERO
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	
	# Determines which axis the producer goes on
	var axis: bool = bool(rng.randi_range(0, 1))
	
	if axis:
		var top: bool = bool(rng.randi_range(0, 1))
		var distance: float = rng.randi_range(1, current_width)
		if top:
			final_vector = Vector2(distance, 0)
		else:
			final_vector = Vector2(distance, current_height)
	else:
		var left: bool = bool(rng.randi_range(0, 1))
		var distance: float = rng.randi_range(1, current_height)
		if left:
			final_vector = Vector2(0, distance)
		else:
			final_vector = Vector2(current_width, distance)
	
	return final_vector

func should_spawn_consumer():
	return current_round % 3 == 0
	
func should_spawn_generator():
	return current_round % 3 == 0
	
func get_map_size() -> Vector2:
	return Vector2(self.current_width * map.cell_size.x, self.current_height * map.cell_size.y)
	
func rotate_inward(object: Node2D) -> void:
	var position: Vector2 = map.get_tile_coords(object.position)

func spawn_generator():
	var coords: Vector2 = rand_wall_coords().floor()
	
	var instance = producer.instance()
	
	if coords.y == 0:
		instance.rotation_degrees = 180
		
	if coords.x == current_width:
		instance.rotation_degrees = 270
		
	if coords.x == 0:
		instance.rotation_degrees = 90
		
	map.place_at_tilev(coords, instance)
	var destroy_coords = map.get_tile_coords(instance.position + instance.spawn_point.position)
	map.place_at_tilev(destroy_coords, place_floor.instance())
	
	emit_signal("generator_placed", instance)
	
func spawn_consumer():
	var coords: Vector2 = rand_coords().floor()
	var instance = consumer.instance()
	map.place_at_tilev(coords, instance)
	rotate_inward(instance)

func expand_room(by):
	current_height += clamp(0, by, by)
	current_width += clamp(0, by, by)
	
	create_current_size()
	
	if should_spawn_consumer():
		spawn_consumer()
		
	if should_spawn_generator():
		spawn_generator()
	
	emit_signal("map_changed", self, current_width, current_height)
