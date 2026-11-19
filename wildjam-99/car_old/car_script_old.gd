extends CharacterBody2D

@onready var wheel_front_left: Sprite2D = %wheel_front_left
@onready var wheel_front_right: Sprite2D = %wheel_front_right

@export var max_steer_angle: float = 20.0
@export var steer_force: float = 90.0
@export var drag_max_deviation: float = 200.0
@export var release_velocity_modifier: float = 5.0
@export var max_release_velocity: float = 2000.0
@export var deceleration: float = 500.0

##Distance (in pixels) between the wheels
var wheel_base := 36.0

var mouse_in_area: bool = false
##Whether or not the car is actively being dragged backwards
var is_dragging: bool = false
##The car's starting position, used to determine how far back the car can be dragged
var starting_position_y := 0.0
##Where the user starts the pullback for the car to release
var pullback_start_pos_y: float
##The current direction of steer for navigating with the wheels
var steer_direction: float

@onready var mouse_drag_area_2d: Area2D = %MouseDragArea2D
@onready var car_sprite: Sprite2D = %CarSprite

func _ready() -> void:
	starting_position_y = global_position.y

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released() and is_dragging:
			var pullback_end_pos_y := get_global_mouse_position().y
			var drag_force := (abs(pullback_end_pos_y - pullback_start_pos_y)) as float
			release_car(drag_force)
			is_dragging = false
			mouse_drag_area_2d.visible = false

func _physics_process(delta: float) -> void:
	var input_axis := Input.get_axis("steer_left", "steer_right")
	
	steer_direction = input_axis * deg_to_rad(max_steer_angle)
	calculate_steering(delta)
	
	steer_wheels(input_axis, delta)
	
	#print(velocity)
	if is_dragging:
		global_position.y = clampf(
			get_global_mouse_position().y, starting_position_y, starting_position_y + drag_max_deviation)
	if velocity != Vector2.ZERO:
		move_and_slide()
		#velocity = velocity.move_toward(Vector2.ZERO, delta * deceleration)
		#velocity = lerp(velocity, Vector2.ZERO, deceleration * delta)

func release_car(drag_force: float) -> void:
	print(drag_force)
	velocity = clamp(
		drag_force * Vector2.UP * release_velocity_modifier, Vector2.UP * max_release_velocity, Vector2.ZERO
		)
	print('Starting Velocity: ', velocity)

func calculate_steering(delta: float) -> void:
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	
	var new_heading = rear_wheel.direction_to(front_wheel)
	#new_heading = new_heading.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))
	
	#print(new_heading)
	
	velocity = new_heading * velocity.length()
	print(velocity)
	rotation = new_heading.angle()

func steer_wheels(input_axis: float, delta: float) -> void:
	
	if not is_equal_approx(input_axis, 0.0):
		wheel_front_left.rotation_degrees = clampf(
			wheel_front_left.rotation_degrees + (input_axis * steer_force * delta) , -max_steer_angle, max_steer_angle)
	else:
		wheel_front_left.rotation_degrees = move_toward(wheel_front_left.rotation_degrees, 0.0, steer_force * delta)
		
	wheel_front_right.rotation_degrees = wheel_front_left.rotation_degrees
	#print(wheel_front_left.rotation_degrees)


func _on_area_2d_mouse_entered() -> void:
	mouse_in_area = true


func _on_area_2d_mouse_exited() -> void:
	mouse_in_area = false


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			pullback_start_pos_y = get_global_mouse_position().y
			is_dragging = true
