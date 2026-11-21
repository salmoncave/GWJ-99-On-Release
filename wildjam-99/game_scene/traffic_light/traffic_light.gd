class_name TrafficLight extends Sprite2D

var current_stage: int = 0
var light_time_seconds: float = 0.5
var height_offset: Vector2 = - Vector2(50.0, 64.0)
var tween: Tween

@onready var lights: AnimatedSprite2D = %Lights
@onready var rich_text_label: RichTextLabel = %RichTextLabel

func place_light_above_player(player: PlayerCar) -> void:
	global_position = player.global_position + height_offset

func enable_traffic_light() -> void:
	current_stage = 0
	visible = true

func disable_traffic_light() -> void:
	current_stage = 0
	visible = false

func start_traffic_light() -> void:
	lights.self_modulate.a = 0.0
	_animate_traffic_light()

func stop_traffic_light() -> void:
	tween.stop()

func _animate_traffic_light() -> void:
	var text :=''
	
	match current_stage:
		0:
			text = 'READY'
		1:
			text = 'SET'
		2:
			text = 'GO!'
	
	rich_text_label.text = text
	
	tween = create_tween()
	var tween_duration := 0.25
	
	#lights.self_modulate.a = 0.0
	tween.tween_property(lights, "self_modulate:a", 1.0, tween_duration)
	tween.tween_property(lights, "self_modulate:a", 0, tween_duration).set_delay(light_time_seconds)
	await tween.finished
	
	current_stage += 1
	lights.frame += 1
	
	if current_stage < 3:
		_animate_traffic_light()
		#light_timer.start(light_time_seconds)
