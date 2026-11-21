class_name RoadObjectSlowdown extends RoadObject

@export var slowdown_multiplier: float = 0.8

func _collide_with_player(_player: PlayerCar) -> void:
	super(_player)
	
	Global.car_speed = clampf(roundf(Global.car_speed * slowdown_multiplier), 200.0, Global.CAR_MAX_SPEED)
