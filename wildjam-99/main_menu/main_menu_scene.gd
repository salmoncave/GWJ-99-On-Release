class_name MainMenuScene extends Node

@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2

@export var buttons: Array[Button]

func _ready() -> void:
	animation_player_2.play_backwards("start_game")

func start_game(difficulty: int) -> void:
	for button in buttons:
		button.disabled = true
	
	Global.reset_global()
	animation_player_2.play("start_game")
	
	await animation_player_2.animation_finished
	
	match difficulty:
		0:
			Global.car_speed = Global.CAR_MIN_SPEED
			Global.starting_spawn_interval = 3.0
			Global.spawn_interval_increase_time = 30.0
			Global.starting_gears = 3
		1:
			Global.car_speed = Global.CAR_MIN_SPEED * 1.5
			Global.starting_spawn_interval = 2.0
			Global.spawn_interval_increase_time = 20.0
			Global.starting_gears = 1
		2:
			Global.car_speed = Global.CAR_MIN_SPEED * 2.0
			Global.starting_spawn_interval = 1.5
			Global.spawn_interval_increase_time = 20.0
			Global.starting_gears = 0
	
	SignalBus.level_started.emit()

func _on_start_button_pressed() -> void:
	start_game(0)

func _on_start_button_2_pressed() -> void:
	start_game(1)

func _on_start_button_3_pressed() -> void:
	start_game(2)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
