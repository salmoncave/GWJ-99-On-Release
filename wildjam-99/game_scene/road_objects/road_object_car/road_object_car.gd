class_name RoadObjectCar extends RoadObject

@export var sprite_array: Array[Texture2D]

func initialize_road_object() -> void:
	object_sprite_2d.texture = sprite_array.pick_random()

func _collide_with_player(_player: PlayerCar) -> void:
	super(_player)
	
