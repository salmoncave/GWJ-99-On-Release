class_name Main extends Node

const GAME_SCENE = preload("uid://bdmn8nbrkcnto")
const MAIN_MENU_SCENE = preload("uid://kmax3xh6p5x1")

var game_scene: GameScene = null
var menu_scene: MainMenuScene = null

func _ready() -> void:
	SignalBus.level_restarted.connect(
		_on_signal_bus_level_restarted
	)
	
	_spawn_main_menu_scene()

func go_to_game() -> void:
	_spawn_new_game_scene()

func _on_signal_bus_level_restarted() -> void:
	if game_scene:
		game_scene.queue_free()
	Global.reset_global()
	_spawn_new_game_scene()

func _spawn_new_game_scene() -> void:
	game_scene = GAME_SCENE.instantiate() as GameScene
	add_child(game_scene)

func _spawn_main_menu_scene() -> void:
	menu_scene = MAIN_MENU_SCENE.instantiate()
	add_child(menu_scene)
