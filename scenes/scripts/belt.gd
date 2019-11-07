extends Area2D

onready var follower = $Path2D/base
onready var path = $Path2D
onready var sprite = $Sprite

var objects: Array = []
var speed: float = 0.1
var direction = Vector2.ZERO

func _ready():
	self.direction = Vector2(cos(self.rotation), -sin(self.rotation))

	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")

# We pop because this has to be the first to be pushed, since
# objects move at a constant rate, the first added will be the 
# first remove, if this logic changes, so does the ordering.
func _on_area_exited(o):
	if o.is_in_group("moveable"):
		objects.erase(o)

func can_claim_ownership(obj):
	return obj.is_in_group("moveable")

func _on_area_entered(obj) -> void:
	if can_claim_ownership(obj):
		objects.push_front(obj)

func _physics_process(delta):
	for child in objects:
		if child.is_in_group("moveable"):
			child.position += (direction * speed)