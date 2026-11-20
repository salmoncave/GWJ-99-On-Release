class_name ParallaxLayers extends Node2D

var default_parallax_layers_autoscroll_speed: Dictionary[Parallax2D, Vector2] = {}

func _ready() -> void:
	default_parallax_layers_autoscroll_speed = _get_parallax_layers_autoscroll_speed()
	
	_update_scroll_speed(Global.car_speed_multiplier)
	SignalBus.car_speed_updated.connect(
		_update_scroll_speed
	)

func _get_parallax_layers_autoscroll_speed() -> Dictionary[Parallax2D, Vector2]:
	var _parallax_layers_autoscroll_speed: Dictionary[Parallax2D, Vector2] = {}
	for child in get_children():
		if child is Parallax2D:
			var parallax_layer := child as Parallax2D
			_parallax_layers_autoscroll_speed[parallax_layer] = parallax_layer.autoscroll
	return _parallax_layers_autoscroll_speed

func _update_scroll_speed(new_scroll_speed_multiplier: float) -> void:
	for layer in _get_parallax_layers_autoscroll_speed():
		layer.autoscroll = default_parallax_layers_autoscroll_speed[layer] * new_scroll_speed_multiplier
