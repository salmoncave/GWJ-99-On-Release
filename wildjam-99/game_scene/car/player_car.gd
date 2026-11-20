class_name PlayerCar extends Node2D

var steer_speed := 200.0
var rotation_degrees_per_frame := 90.0
##The maximum rotation that the car can do per frame, should feel a little bouncy
##but not stiff
var max_rotation_degrees := 5.0
##Whether or not the car has been launched through pulling back and letting go
var has_been_launched: bool = false

var gears := 1

var _default_sprite_scale: Vector2 = Vector2.ONE

@onready var car_sprite: Sprite2D = %CarSprite

func _ready() -> void:
	#animate_car_bounce()
	has_been_launched = true
	
	_default_sprite_scale = scale
	#SignalBus.car_speed_updated.connect(_on_car_speed_multiplier_updated)

#func _physics_process(delta: float) -> void:
	#if has_been_launched:
		#var input_axis := Input.get_axis("steer_up", "steer_down")
		#_rotate_with_steering(input_axis, delta)
		#velocity = Vector2(0.0, steer_speed * input_axis)
		#move_and_slide()

func _rotate_with_steering(input_axis: float, delta: float) -> void:
	if not is_equal_approx(input_axis, 0.0):
		rotation_degrees = clampf(
			rotation_degrees + (input_axis * rotation_degrees_per_frame * delta), -max_rotation_degrees, max_rotation_degrees
		)
	else:
		rotation_degrees = move_toward(rotation_degrees, 0.0, rotation_degrees_per_frame / 2.0 * delta)

#Want it to thin out car as it gets faster, will return later if extra time alotted
#func _on_car_speed_multiplier_updated(new_car_speed_multiplier: float) -> void:
	#var thinning_force := Vector2(1.05, 0.95)
	#car_sprite.scale.x = pow(_default_sprite_scale.x, new_car_speed_multiplier)
	#thinning_force * new_car_speed_multiplier

#func animate_car_bounce() -> void:
	#var scale_00 := car_sprite.scale * Vector2(0.95, 1.15)
	##var scale_01 := car_sprite.scale * Vector2(1.15, 0.95)
	#var scale_default := car_sprite.scale
	#var tween_duration := 0.25
	#var tween := create_tween()
	#tween.set_loops()
	#tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	#tween.tween_property(
		#car_sprite, 'scale', scale_00, tween_duration
		#)
	#tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	#tween.tween_property(
		#car_sprite, 'scale', scale_default, tween_duration
		#)

func switch_lane_up() -> void:
	pass

func switch_lane_down() -> void:
	pass
