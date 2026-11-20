extends Node

##Should go up as the level continues, actually drives the scale of scrolling
var car_speed_multiplier := 1.0:
		set(value):
			car_speed_multiplier = value
			cosmetic_speed = car_speed_multiplier * _cosmetic_speed_multiplier
			SignalBus.car_speed_updated.emit(car_speed_multiplier)

var cosmetic_speed := 10.0

var _cosmetic_speed_multiplier := 55.0

func reset_car_speed() -> void:
	car_speed_multiplier = 1.0
