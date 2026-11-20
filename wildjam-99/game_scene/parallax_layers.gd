class_name ParallaxLayers extends Node2D

@export var layers_auto_scroll_multiplier: Dictionary[Parallax2D, float] = {}
#var default_parallax_layers_autoscroll_speed: Dictionary[Parallax2D, Vector2] = {}

func _ready() -> void:
	#default_parallax_layers_autoscroll_speed = _get_parallax_layers_autoscroll_speed()
	
	_on_signal_bus_car_speed_updated(Global.car_speed)
	
	
	SignalBus.car_speed_updated.connect(_on_signal_bus_car_speed_updated)

#func _get_parallax_layers_autoscroll_speed() -> Dictionary[Parallax2D, Vector2]:
	#var _parallax_layers_autoscroll_speed: Dictionary[Parallax2D, Vector2] = {}
	#for child in get_children():
		#if child is Parallax2D:
			#var parallax_layer := child as Parallax2D
			#_parallax_layers_autoscroll_speed[parallax_layer] = parallax_layer.autoscroll
	#return _parallax_layers_autoscroll_speed

func _on_signal_bus_car_speed_updated(new_car_speed: float) -> void:
	for layer in layers_auto_scroll_multiplier:
		layer.autoscroll.x = - layers_auto_scroll_multiplier[layer] * new_car_speed
