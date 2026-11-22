class_name Main extends Node

const GAME_SCENE = preload("uid://bdmn8nbrkcnto")
const MAIN_MENU_SCENE = preload("uid://kmax3xh6p5x1")

var game_scene: GameScene = null
var menu_scene: MainMenuScene = null

func _ready() -> void:
	SignalBus.level_started.connect(
		_on_signal_bus_level_started
	)
	SignalBus.main_menu_requested.connect(
		_spawn_main_menu_scene
	)
	
	_spawn_main_menu_scene()

func go_to_game() -> void:
	_spawn_new_game_scene()

func go_to_main_menu() -> void:
	_spawn_main_menu_scene()

func _on_signal_bus_level_started() -> void:
	Global.reset_global()
	_spawn_new_game_scene()

func _clear_scenes() -> void:
	if game_scene:
		game_scene.queue_free()
	if menu_scene:
		menu_scene.queue_free()

func _spawn_new_game_scene() -> void:
	_clear_scenes()
	game_scene = GAME_SCENE.instantiate() as GameScene
	add_child(game_scene)

func _spawn_main_menu_scene() -> void:
	_clear_scenes()
	menu_scene = MAIN_MENU_SCENE.instantiate()
	add_child(menu_scene)
