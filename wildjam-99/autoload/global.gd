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
var car_speed := 250.0:
		set(value):
			car_speed = clampf(value, 0.0, CAR_MAX_SPEED)
			#cosmetic_speed = car_speed_multiplier * _cosmetic_speed_multiplier
			SignalBus.car_speed_updated.emit(car_speed)

#var cosmetic_speed := 10.0

#var _cosmetic_speed_multiplier := 55.0

var score: int = 0

var gears: int = 1:
	set(value):
		gears = clampi(value, 0, 3)
		SignalBus.num_gears_updated.emit(gears)

func reset_car_speed() -> void:
	car_speed = 0.0

func _physics_process(delta: float) -> void:
	if car_speed > 0.0:
		var score_value := clampi(roundi(car_speed * AESTHETIC_SCORE_MULTIPLIER * delta), 1, 999)
		score += score_value
