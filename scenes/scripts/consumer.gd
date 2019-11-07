extends Area2D

onready var text = $Sprite/Label
onready var texture = $Sprite/TextureRect
onready var item = preload("res://scenes/scripts/item.gd")

export var want: String = "egg"

var distance_out: int = 0
var requires: int = 5
var has: int = 0

func _ready():
	connect("area_entered", self, "_on_area_entered")
	texture.texture = load("res://scenes/items/" + want + ".tscn").instance().get_node("item").texture
	
func _on_area_entered(obj):
	if obj is item && has < requires:
		has += 1
		obj.queue_free()
		
func _physics_process(delta):
	text.text = "%d/%d" % [has, requires]
	
func set_distance_out(distance_out: int) -> void:
	self.distance_out = distance_out
