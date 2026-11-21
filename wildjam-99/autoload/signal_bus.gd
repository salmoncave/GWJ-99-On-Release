extends Node

@warning_ignore_start("unused_signal")
##Emitted by: Global
signal car_speed_updated(new_car_speed: float)

signal num_gears_updated(new_num_gears: int)

##Picked up gear
signal gear_collected(collect_position: Vector2)
##Hit car, had gear to spend
signal gear_spent
##Lost gear from hitting object
signal gear_lost

signal spawn_temporary_speed_lines
