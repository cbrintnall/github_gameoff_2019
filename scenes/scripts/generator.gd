extends Node2D

export var scene: PackedScene

onready var timer: Timer = $Timer;
onready var spawn_point: Node2D = $spawn_point;

func _ready():
	timer.connect("timeout", self, "_on_timeout")
	
func _on_timeout():
	spawn()
	
func spawn():
	var instance = scene.instance()
	instance.position = spawn_point.position
	add_child(instance)