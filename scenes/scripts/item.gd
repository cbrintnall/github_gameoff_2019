extends KinematicBody2D

onready var shape: CollisionShape2D = $CollisionShape2D
onready var sprite: Sprite = $item

export var item_name: String

var max_speed: float = 0.4

func move_item(direction: Vector2, speed: float):
	self.position += (direction * clamp(speed, 0.0, max_speed))

func move_and_slide(linear_velocity: Vector2, 
					floor_normal: Vector2 = Vector2.ZERO, 
					stop_on_slope: bool = false, 
					max_slides: int = 4,
					floor_max_angle: float = 0.785398, 
					infinite_inertia: bool = true):
						
	print("Moving!")

	var true_velocity: Vector2 = Vector2(
		clamp(linear_velocity.x, 0.0, max_speed), 
		clamp(linear_velocity.y, 0.0, max_speed)
	)
	
	.move_and_slide(true_velocity, floor_normal, stop_on_slope, max_slides, floor_max_angle, infinite_inertia)