class_name Car extends VehicleBody3D

var steer_force: float = 3.0
@export var deceleration: float = 100.0
@export var starting_engine_force := 200.0

func _ready() -> void:
	engine_force = starting_engine_force

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_axis("steer_right", "steer_left")
	
	engine_force = clampf(engine_force - (deceleration * delta), 0.0, 200.0)
	
	var steer_vector := input_vector * steer_force * delta
	steering = clampf(steering + steer_vector, -0.2, 0.2)
	
