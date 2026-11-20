extends CharacterBody2D

##The angle by which the car attempts to steer when L/R is engaged
@export var steering_angle := 15
@export var friction := -20.0
@export var drag := -0.06
@export var max_speed_reverse := 250
@export var slip_speed := 400
@export var traction_fast := 2.5
@export var traction_slow := 10.0
@export var max_speed: float = 5000.0

@export_group('Pullback', 'pullback')
@export var pullback_release_velocity_modifier: float = 10.0
@export var pullback_max_release_velocity: float = 5000.0
@export var pullback_max_deviation: float = 300.0

@export_group('Wheel Animation', 'wheel')
@export var wheel_animation_rotate_force: float = 90.0
@export var wheel_animation_steer_angle: float = 30.0

##The current acceleration of the vehicle, I don't think this is often used given the
##lack of typical acceleration and deceleration by arrow keys
var acceleration = Vector2.ZERO
##The active direction of the car's steering, determined by the simulated wheels
var steer_direction: float
##Distance (in pixels) between the wheels
var wheel_base := 36
##Whether or not the mouse is in the pullback area
var mouse_in_area: bool = false
##Whether or not the user is actively pulling the car back to start the level
var is_pulling_back_car: bool = false
##The starting y position of the mouse during pullback, used to compare to where the mouse is being released
var pullback_start_pos_y: float
##The starting y position of the vehicle, used to make sure the car isn't pulled back too far
var starting_position: Vector2


@onready var wheel_front_left: Sprite2D = %wheel_front_left
@onready var wheel_front_right: Sprite2D = %wheel_front_right
@onready var mouse_drag_area_2d: Area2D = %MouseDragArea2D

func _ready() -> void:
	starting_position = global_position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released() and is_pulling_back_car:
			var drag_end_pos_y := get_global_mouse_position().y
			var release_force := (abs(drag_end_pos_y - pullback_start_pos_y)) as float
			_release_car(release_force)
			is_pulling_back_car = false
			mouse_drag_area_2d.visible = false

func _physics_process(delta):
	if is_pulling_back_car:
		global_position.y = clampf(
			get_global_mouse_position().y, starting_position.y, starting_position.y + pullback_max_deviation)
	
	acceleration = Vector2.ZERO
	
	var input_axis = Input.get_axis("steer_left", "steer_right")
	steer_direction = input_axis * deg_to_rad(steering_angle)
	
	_animate_wheel_rotation(input_axis, delta)
	_apply_friction(delta)
	_calculate_steering(delta)
	velocity += acceleration * delta
	move_and_slide()
	
	$Label.text = str(snappedf(global_position.distance_to(starting_position), 0.1))
	$Label2.text = str(snappedf(velocity.length(), 0.1))

func _release_car(release_force: float) -> void:
	print(release_force)
	velocity = clamp(
		release_force * Vector2.UP * pullback_release_velocity_modifier, Vector2.UP * pullback_max_release_velocity, Vector2.ZERO
		)
	print('Starting Velocity: ', velocity)

func _apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

func _calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = rear_wheel.direction_to(front_wheel)
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	
	rotation = new_heading.angle()

func _animate_wheel_rotation(input_axis: float, delta: float) -> void:
	if not is_equal_approx(input_axis, 0.0):
		wheel_front_left.rotation_degrees = clampf(
			wheel_front_left.rotation_degrees + (input_axis * wheel_animation_rotate_force * delta) , -wheel_animation_steer_angle, wheel_animation_steer_angle)
	else:
		wheel_front_left.rotation_degrees = move_toward(wheel_front_left.rotation_degrees, 0.0, wheel_animation_rotate_force * delta)
		
	wheel_front_right.rotation_degrees = wheel_front_left.rotation_degrees

func _on_mouse_drag_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			pullback_start_pos_y = get_global_mouse_position().y
			is_pulling_back_car = true

func _on_mouse_drag_area_2d_mouse_entered() -> void:
	mouse_in_area = true

func _on_mouse_drag_area_2d_mouse_exited() -> void:
	mouse_in_area = false
