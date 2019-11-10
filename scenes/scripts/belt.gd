extends Area2D

onready var sprite = $Sprite
onready var collider = $CollisionShape2D

var objects: Array = []
var speed: float = 0.1
var direction = Vector2.ZERO

func _ready():
	self.direction = Vector2(cos(self.rotation), -sin(self.rotation))
	
	print(direction)

	connect("body_entered", self, "_on_area_entered")
	connect("body_exited", self, "_on_area_exited")

# We pop because this has to be the first to be pushed, since
# objects move at a constant rate, the first added will be the 
# first remove, if this logic changes, so does the ordering.
func _on_area_exited(o):
	if o.is_in_group("moveable"):
		objects.erase(o)

func _on_area_entered(obj) -> void:
	if can_claim_ownership(obj):
		objects.push_front(obj)

func _physics_process(delta):
	for child in objects:
		if child.is_in_group("moveable"):
			self.move_along(child)

func move_to_center(object: Node2D) -> void:
	var center: Vector2 = self.get_center_point()
	var dirTo: Vector2 = object.position.direction_to(center)
	var vertical: bool = abs(dirTo.y) > abs(dirTo.x)
	
	if vertical:
		dirTo = Vector2(0, dirTo.y)
	else:
		dirTo = Vector2(dirTo.x, 0)

	if object.position != center:
		object.move_and_collide(dirTo * speed)

func move_along(object: Node2D) -> void:
	object.move_item(direction, speed)
			
func get_center_point() -> Vector2:
	return self.position + (collider.shape.get_extents()).floor()
			
func can_claim_ownership(obj):
	return obj.is_in_group("moveable")