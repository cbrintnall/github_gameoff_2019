extends Area2D

onready var audio = $AudioStreamPlayer2D
onready var text = $Sprite/Label
onready var texture = $Sprite/TextureRect
onready var item = preload("res://scenes/scripts/item.gd")

export var want: String = "egg"

var distance_out: int = 0

# TODO: If requires is -1, it will eat ALWAYS
var requires: int = -1
var has: int = 0

func _ready():
	connect("body_entered", self, "_on_area_entered")
	texture.texture = load("res://scenes/items/" + want + ".tscn").instance().get_node("item").texture
	
func _on_area_entered(obj):
	if obj is item && (has < requires || requires == -1):
		pickup_object(obj)
		
func pickup_object(obj) -> void:
	has += 1
	
	if !audio.playing:
		audio.play(0.0)
	
	obj.queue_free()
		
func _physics_process(delta):
	var out_of: String = str(requires)
	
	if requires == -1:
		out_of = ""
	
	text.text = "%d/%d" % [has, requires]
	
func set_distance_out(distance_out: int) -> void:
	self.distance_out = distance_out
	
func finished():
	pass

