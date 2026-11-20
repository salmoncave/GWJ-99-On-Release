class_name GameSceneCamera2D extends Camera2D

@export var player_car: PlayerCar

var is_zooming: bool = false
var zoom_duration: float = 0.75
var zoom_max: float = 2.0

#func _physics_process(_delta: float) -> void:
	#if Input.is_action_just_pressed("debug_00"):
		#perform_camera_zoom(true)
	#elif Input.is_action_just_pressed("debug_01"):
		#perform_camera_zoom(false)

#func zoom_in_on_player(delta: float) -> void:
	#global_position = global_position.move_toward(player_car.global_position, move_speed * delta)
	#zoom = zoom.move_toward(Vector2.ONE * zoom_max, zoom_speed * delta)

func perform_camera_zoom(is_zoom_in: bool) -> void:
	is_zooming = true
	var zoom_tween := create_tween()
	
	zoom_tween.finished.connect(_on_zoom_tween_finished)
	
	var desired_zoom := Vector2.ONE * 2.0 if is_zoom_in else Vector2.ONE
	var desire_position := player_car.global_position if is_zoom_in else Vector2.ZERO
	var desired_ease := Tween.EASE_IN if is_zoom_in else Tween.EASE_OUT
	
	zoom_tween.set_parallel(true)
	zoom_tween.set_ease(desired_ease).set_trans(Tween.TRANS_SINE)
	zoom_tween.tween_property(self, "zoom", desired_zoom, zoom_duration)
	zoom_tween.tween_property(self, "global_position", desire_position, zoom_duration)

func _on_zoom_tween_finished() -> void:
	is_zooming = false
