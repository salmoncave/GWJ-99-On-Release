class_name RoadObject extends Node2D

signal player_collided_with_road_object

@onready var object_sprite_2d: Sprite2D = %ObjectSprite2D

func initialize_road_object() -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area.owner is PlayerCar:
		_collide_with_player(area.owner)

func _collide_with_player(_player: PlayerCar) -> void:
	print(_player)
	player_collided_with_road_object.emit()

func _physics_process(delta: float) -> void:
	if not is_equal_approx(Global.car_speed, 0.0):
		global_position.x -= delta * Global.car_speed
