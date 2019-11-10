extends Node2D

export var scene: PackedScene

onready var sprite: Sprite = $Sprite;
onready var timer: Timer = $Timer;
onready var spawn_point: Node2D = $spawn_point;
onready var audio: AudioStreamPlayer2D = $spawn_point/AudioStreamPlayer2D;
onready var anti_spawn_area: Area2D = $spawn_point/Area2D;
onready var spawn_particles: Particles2D = $spawn_point/Particles2D2;

func _ready():
	timer.connect("timeout", self, "_on_timeout")
	
func _on_timeout():
	var overlaps = anti_spawn_area.get_overlapping_bodies();
	
	if len(overlaps) == 0:
		spawn()
	else:
		pass
		
func is_blocked():
	sprite.modulate = Color(100, 0, 0, 255)
	
func reset_color():
	sprite.modulate = Color(0, 0, 0, 255)
	
func spawn():
	var instance = scene.instance()
	instance.position = spawn_point.position
	instance.rotation_degrees -= self.rotation_degrees

	if !audio.playing:
		audio.play(0.0)
		
	spawn_particles.set_emitting(true)
	add_child(instance)