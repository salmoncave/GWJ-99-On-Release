class_name GameHUD extends Control

@onready var speed_text_label: RichTextLabel = %SpeedTextLabel
@export var color_gradient: Gradient
@export var aesthetic_speed_divisor: float = 10.0

func _ready() -> void:
	SignalBus.car_speed_updated.connect(
		_on_signal_bus_car_speed_updated
	)

func _on_signal_bus_car_speed_updated(new_speed: float) -> void:
	speed_text_label.text = str(roundi(new_speed / aesthetic_speed_divisor))
	speed_text_label.self_modulate = color_gradient.sample(new_speed / Global.CAR_MAX_SPEED)
