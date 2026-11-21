class_name RoadObjectBoost extends RoadObject

@export var boost_multiplier: float = 1.1

func _collide_with_player(_player: PlayerCar) -> void:
	super(_player)
	
	Global.car_speed = roundf(Global.car_speed * boost_multiplier)
	SignalBus.spawn_temporary_speed_lines.emit()
