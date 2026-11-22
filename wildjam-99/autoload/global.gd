extends Node

enum CarSizes {
	SMALL,
	MEDIUM,
	LARGE
}

const CAR_MIN_SPEED := 250.0
const CAR_MAX_SPEED := 2500.0
const AESTHETIC_SCORE_MULTIPLIER := 0.5

##Should go up as the level continues, actually drives the scale of scrolling
var car_speed := CAR_MIN_SPEED:
		set(value):
			car_speed = clampf(value, 0.0, CAR_MAX_SPEED)
			#cosmetic_speed = car_speed_multiplier * _cosmetic_speed_multiplier
			SignalBus.car_speed_updated.emit(car_speed)
			if car_speed > top_speed:
				top_speed = car_speed

#var cosmetic_speed := 10.0

#var _cosmetic_speed_multiplier := 55.0

var score: int = 0

var top_speed: float = 0
var launches: int = 0

var starting_spawn_interval: float = 2.5
var spawn_interval_increase_time: float = 30.0
var starting_gears: int = 3

var road_lines: bool = true: 
	set(value):
		road_lines = value
		SignalBus.road_lines_toggled.emit(road_lines)

func reset_global() -> void:
	car_speed = CAR_MIN_SPEED
	score = 0
	top_speed = 0.0
	launches = 0

func _physics_process(delta: float) -> void:
	if not is_equal_approx(car_speed, 0.0):
		var score_value := clampi(roundi(car_speed * AESTHETIC_SCORE_MULTIPLIER * delta), 1, 999)
		score += score_value
