class_name MainMenuScene extends Node

@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2

@export var buttons: Array[Button]

@export var button_sound_pressed: AudioStream
@export var button_sound_hovered: AudioStream
@export var menu_music: AudioStream
@export var level_music: AudioStream

func _ready() -> void:
	AudioManager.set_new_music_track(menu_music)
	_toggle_button_disable(true)
	animation_player_2.play_backwards("start_game")
	await animation_player_2.animation_finished
	_toggle_button_disable(false)
	
	for button in buttons:
		button.mouse_entered.connect(func():
			AudioManager.spawn_sound_emitter(button_sound_hovered))
		button.pressed.connect(func():
			AudioManager.spawn_sound_emitter(button_sound_pressed))

func _toggle_button_disable(is_disabled: bool) -> void:
	for button in buttons:
		button.disabled = is_disabled

func start_game(difficulty: int) -> void:
	_toggle_button_disable(true)
	Global.reset_global()
	animation_player_2.play("start_game")
	
	AudioManager.set_new_music_track(level_music, 5.0)
	
	await animation_player_2.animation_finished
	
	match difficulty:
		0:
			Global.car_starting_speed = Global.CAR_MIN_SPEED
			Global.starting_spawn_interval = 3.0
			Global.spawn_interval_increase_time = 30.0
			Global.starting_gears = 3
		1:
			Global.car_starting_speed = Global.CAR_MIN_SPEED * 1.5
			Global.starting_spawn_interval = 2.0
			Global.spawn_interval_increase_time = 22.0
			Global.starting_gears = 1
		2:
			Global.car_starting_speed = Global.CAR_MIN_SPEED * 2.0
			Global.starting_spawn_interval = 1.5
			Global.spawn_interval_increase_time = 15.0
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
