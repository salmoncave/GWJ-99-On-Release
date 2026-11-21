class_name GameHUD extends Control

@export var color_gradient: Gradient
@export var aesthetic_speed_multiplier: float = 0.1

var max_speed_speedometer := 2000.0
var previous_speed := 0.0

@onready var speed_text_label: RichTextLabel = %SpeedTextLabel
@onready var score_text_label: RichTextLabel = %ScoreTextLabel
@onready var speed_texture_progress_bar: TextureProgressBar = %SpeedTextureProgressBar
@onready var gear_texture_progress_bar: TextureProgressBar = %GearTextureProgressBar

func _ready() -> void:
	SignalBus.car_speed_updated.connect(
		_on_signal_bus_car_speed_updated
	)
	
	SignalBus.num_gears_updated.connect(
		_on_signal_bus_num_gears_updated
	)
	
	gear_texture_progress_bar.value = Global.gears

func _physics_process(_delta: float) -> void:
	score_text_label.text = str(Global.score)

func _on_signal_bus_car_speed_updated(new_speed: float) -> void:
	speed_text_label.text = str(roundi(new_speed * aesthetic_speed_multiplier))
	speed_text_label.self_modulate = color_gradient.sample(new_speed / Global.CAR_MAX_SPEED)
	speed_texture_progress_bar.value = snappedf((new_speed / max_speed_speedometer) * 100, 1.0)
	
	var is_increase := previous_speed < new_speed
	previous_speed = new_speed
	_tween_speed_label_scale(is_increase)

func _tween_speed_label_scale(is_increase: bool) -> void:
	var scale_tween := create_tween()
	var tween_duration := 0.25
	var default_value := Vector2.ONE
	var scaled_value := Vector2.ONE * 1.20 if is_increase else Vector2.ONE * 0.80
	
	scale_tween.tween_property(speed_text_label, "offset_transform_scale", scaled_value, tween_duration)
	scale_tween.tween_property(speed_text_label, "offset_transform_scale", default_value, tween_duration)
	

func _on_signal_bus_num_gears_updated(new_num_gears: int) -> void:
	gear_texture_progress_bar.value = new_num_gears
	
	
