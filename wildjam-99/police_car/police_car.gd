class_name PoliceCar extends CharacterBody2D

var steer_speed := 200.0
var rotation_degrees_per_frame := 90.0
var max_rotation_degrees := 5.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var input_axis := Input.get_axis("steer_up", "steer_down")
	_rotate_with_steering(input_axis, delta)
	velocity = Vector2(0.0, steer_speed * input_axis)
	move_and_slide()

func _rotate_with_steering(input_axis: float, delta: float) -> void:
	if not is_equal_approx(input_axis, 0.0):
		rotation_degrees = clampf(
			rotation_degrees + (input_axis * rotation_degrees_per_frame * delta), -max_rotation_degrees, max_rotation_degrees
		)
	else:
		rotation_degrees = move_toward(rotation_degrees, 0.0, rotation_degrees_per_frame / 2.0 * delta)

func switch_lane_up() -> void:
	pass

func switch_lane_down() -> void:
	pass
