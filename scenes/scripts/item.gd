extends KinematicBody2D

onready var shape: CollisionShape2D = $CollisionShape2D
onready var sprite: Sprite = $item

export var item_name: String

var max_speed: float = 0.4

func move_item(direction: Vector2, speed: float):
	self.move_and_collide(direction * clamp(speed, 0.0, max_speed))