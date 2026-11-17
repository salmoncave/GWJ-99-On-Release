class_name BoostPad extends Node2D

@export var velocity_boost_force: float = 10.0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Car:
		var car := body as Car
		#var new_car_velocity := car.velocity.clamp(car.velocity, car.velocity * maxs)
		car.velocity *= velocity_boost_force * Vector2.UP
