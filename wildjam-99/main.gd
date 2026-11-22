class_name Main extends Node

const GAME_SCENE = preload("uid://bdmn8nbrkcnto")

var game_scene: GameScene = null

func _ready() -> void:
	SignalBus.level_restarted.connect(
		_on_signal_bus_level_restarted
	)
	
	_spawn_new_game_scene()

func _on_signal_bus_level_restarted() -> void:
	if game_scene:
		game_scene.queue_free()
	Global.reset_global()
	_spawn_new_game_scene()

func _spawn_new_game_scene() -> void:
	game_scene = GAME_SCENE.instantiate() as GameScene
	add_child(game_scene)
