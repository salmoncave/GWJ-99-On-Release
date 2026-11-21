class_name RoadObject extends Node2D

signal player_collided_with_road_object

var x_pos_delete: float
var lane: int = 0

@onready var object_sprite_2d: Sprite2D = %ObjectSprite2D
@onready var animated_object_sprite_2d: AnimatedSprite2D = %AnimatedObjectSprite2D

func initialize_road_object() -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area.owner is PlayerCar:
		_collide_with_player(area.owner)

func _collide_with_player(_player: PlayerCar) -> void:
	print('Player Collided With: ', self)
	player_collided_with_road_object.emit()

func _physics_process(delta: float) -> void:
	if not is_equal_approx(Global.car_speed, 0.0):
		global_position.x -= delta * Global.car_speed
	if global_position.x <= x_pos_delete:
		queue_free()
