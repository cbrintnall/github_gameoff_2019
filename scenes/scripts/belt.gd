extends Area2D

onready var follower = $Path2D/base
onready var path = $Path2D
onready var sprite = $Sprite

var move_queue: Array = []
var speed: float = 0.01

func _ready():
	connect("area_entered", self, "_on_area_entered")

func can_claim_ownership(obj):
	return !(obj in move_queue) && obj.is_in_group("moveable") && !obj.get_parent().is_in_group("conveyor")

func _on_area_entered(obj) -> void:
	if can_claim_ownership(obj):
		move_queue.append(obj)
	
func claim_ownership(object):
	var parent = object.get_parent()
	parent.remove_child(object)
	object.position = path.position
	self.add_child(object)
	
func unload_queue():
	for i in move_queue.size():
		self.claim_ownership(move_queue[i])
		move_queue.remove(i)

func add_child(obj, legible_unique_name=false):
	var new_path = follower.duplicate()
	new_path.set_unit_offset(0.0)
	path.add_child(new_path)
	new_path.add_child(obj)
	
	print("Added child!")
	
func get_paths() -> Array:
	var children: Array = []
	var path_children: Array = path.get_children()
	
	# Add all child paths that aren't the base path
	for child in path_children:
		if child.name != "base":
			children.append(child)

	return children

func _physics_process(delta):
	if len(move_queue) > 0:
		self.unload_queue()

	var paths: Array = self.get_paths()

	for follow in paths:
		var offset: float = follow.get_unit_offset()

		if offset >= 1.0:
			follow.queue_free()

		follow.set_unit_offset(offset + speed)