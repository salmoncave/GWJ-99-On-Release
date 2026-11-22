class_name GameHUD extends Control

signal unpause

@export var color_gradient: Gradient
@export var aesthetic_speed_multiplier: float = 0.1
@export var gear_markers: Array[Marker2D]
@export var gear_texture: Texture2D

@export var button_hover_sfx: AudioStream
@export var button_click_sfx: AudioStream

@export var buttons: Array[Button]

var max_speed_speedometer := 2000.0
var previous_speed := 0.0

@onready var speed_text_label: RichTextLabel = %SpeedTextLabel
@onready var score_text_label: RichTextLabel = %ScoreTextLabel
@onready var speed_texture_progress_bar: TextureProgressBar = %SpeedTextureProgressBar
@onready var gear_texture_progress_bar: TextureProgressBar = %GearTextureProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var speed_label: RichTextLabel = %SpeedLabel
@onready var launches_label: RichTextLabel = %LaunchesLabel
@onready var score_label: RichTextLabel = %ScoreLabel
@onready var hud_root: MarginContainer = %HudRoot

@onready var road_lines_check_box: Button = %RoadLinesCheckBox
@onready var speed_lines_check_box: Button = %SpeedLinesCheckBox
@onready var music_button: Button = %MusicButton
@onready var sfx_button: Button = %SFXButton

func _ready() -> void:
	road_lines_check_box.button_pressed = Global.road_lines
	speed_lines_check_box.button_pressed = Global.speed_lines
	
	music_button.button_pressed = AudioManager.is_music_muted
	sfx_button.button_pressed = AudioManager.is_sfx_muted
	
	SignalBus.car_speed_updated.connect(
		_on_signal_bus_car_speed_updated
	)
	
	for button in buttons:
		button.mouse_entered.connect(
			func(): AudioManager.spawn_sound_emitter(button_hover_sfx)
		)
		button.pressed.connect(
			func(): AudioManager.spawn_sound_emitter(button_click_sfx)
		)

func show_game_over_panel() -> void:
	speed_label.text = str(int(Global.top_speed * aesthetic_speed_multiplier))
	launches_label.text = str(Global.launches)
	score_label.text = str(Global.score)
	animation_player.play("game_over")

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
	


func _on_retry_button_pressed() -> void:
	SignalBus.level_started.emit()


func _on_quit_button_pressed() -> void:
	SignalBus.main_menu_requested.emit()


func _on_road_lines_check_box_toggled(toggled_on: bool) -> void:
	Global.road_lines = toggled_on


func _on_resume_button_pressed() -> void:
	unpause.emit()


func _on_speed_lines_check_box_toggled(toggled_on: bool) -> void:
	SignalBus.speed_lines_toggled.emit(toggled_on)


func _on_music_button_toggled(toggled_on: bool) -> void:
	AudioManager.is_music_muted = toggled_on

func _on_sfx_button_toggled(toggled_on: bool) -> void:
	AudioManager.is_sfx_muted = toggled_on
	AudioManager.is_ambience_muted = toggled_on
