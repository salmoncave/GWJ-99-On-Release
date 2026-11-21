extends Node

enum CarSizes {
	SMALL,
	MEDIUM,
	LARGE
}

const CAR_MAX_SPEED := 2500.0

##Should go up as the level continues, actually drives the scale of scrolling
var car_speed := 250.0:
		set(value):
			car_speed = value
			#cosmetic_speed = car_speed_multiplier * _cosmetic_speed_multiplier
			SignalBus.car_speed_updated.emit(car_speed)

#var cosmetic_speed := 10.0

#var _cosmetic_speed_multiplier := 55.0

func reset_car_speed() -> void:
	car_speed = 0.0
