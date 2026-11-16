extends Camera3D

@export var follow_target: Node3D
@export var look_at_target: Node3D
@export var height_offset: float = 10.0

func _physics_process(delta: float) -> void:
	global_position = look_at_target.global_position + Vector3(0.0, height_offset, 0.0)
	#look_at(look_at_target.global_position)
