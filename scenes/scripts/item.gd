extends KinematicBody2D

onready var shape: CollisionShape2D = $CollisionShape2D
onready var sprite: Sprite = $item

export var item_name: String