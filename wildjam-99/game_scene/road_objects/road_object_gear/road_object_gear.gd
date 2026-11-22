class_name RoadObjectGear extends RoadObject

func _collide_with_player(_player: PlayerCar) -> void:
	super(_player)
	queue_free()
