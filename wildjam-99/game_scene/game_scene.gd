class_name GameScene extends Node

@export var player: PlayerCar = null

@export var lane_markers_center: Array[Marker2D] = []
@onready var game_scene_camera_2d: GameSceneCamera2D = %GameSceneCamera2D
@onready var speed_line_color_rect: ColorRect = %SpeedLineColorRect
@onready var traffic_light: TrafficLight = %TrafficLight
@onready var hud: GameHUD = %Hud
@onready var road_object_spawner: RoadObjectSpawner = %RoadObjectSpawner

var current_lane: int = 0
var _num_lanes: int = 4
var _lane_shift_speed: float = 300.0

var _is_changing_lanes: bool = false
var _in_pullback_cutscene: bool = false
var _is_pulling_back_car: bool = false

var _pre_pull_back_speed: float = 0.0
#var _pre_pull_player_x: float = 0.0
var _max_pull_back_deviation_x: float = 100.0
var _pull_back_speed: float = 200.0
#var _stored_launch_force: float = 0.0
#var _launch_speed_stage: int = 0
var _launch_speed_stage_multipler := [0.8, 1.0, 1.2, 0.8]

func _ready() -> void:
	_place_player_on_lane(0)
	_start_pull_back_cutscene()
	
	#pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_00"):
		_start_pull_back_cutscene()
	
	if _in_pullback_cutscene:
		if Input.is_action_just_pressed("pull_back") and not _is_pulling_back_car:
			_start_pull_back()
		if _is_pulling_back_car:
			_process_pull_back(delta)
		return
	
	_process_player_movement(delta)

func _start_pull_back() -> void:
	#_pre_pull_player_x = player.global_position.x
	traffic_light.place_light_above_player(player)
	traffic_light.enable_traffic_light()
	traffic_light.start_traffic_light()
	_is_pulling_back_car = true

##Do spacebar first and add mouse later
##Pull back to extent, time it release with green light
##Multiplier for each color stage they waited I guess
func _process_pull_back(delta: float) -> void:
	if traffic_light.current_stage == 3 or Input.is_action_just_released("pull_back"):
		_launch_car(_pre_pull_back_speed)
	elif Input.is_action_pressed("pull_back"):
		player.car_sprite.position.x = clampf(
			player.car_sprite.position.x - (_pull_back_speed * delta), - _max_pull_back_deviation_x, 0.0)

		#_launch_car(_pre_pull_back_speed * _launch_speed_stage_multipler[_launch_speed_stage])

func _launch_car(launch_force: float) -> void:
	var tween_duration := 50.0 / launch_force
	var release_tween := create_tween()
	var starting_mask_size := 1.0
	var ending_mask_size := 0.1
	
	game_scene_camera_2d.perform_camera_zoom(false)
	_set_speed_line_mask_size(starting_mask_size)
	speed_line_color_rect.visible = true
	release_tween.set_parallel(true)
	release_tween.tween_property(player.car_sprite, "position", Vector2.ZERO, tween_duration)
	release_tween.tween_method(_set_speed_line_mask_size, starting_mask_size, ending_mask_size, tween_duration)
	await release_tween.finished
	
	_in_pullback_cutscene = false
	
	traffic_light.stop_traffic_light()
	
	Global.car_speed = roundf(launch_force * _launch_speed_stage_multipler[traffic_light.current_stage])
	
	traffic_light.disable_traffic_light()
	hud.visible = true
	road_object_spawner.resume_spawning_objects()
	
	release_tween = create_tween()
	release_tween.tween_method(_set_speed_line_mask_size, ending_mask_size, starting_mask_size, 7.5)
	await release_tween.finished
	speed_line_color_rect.visible = false

func _set_speed_line_mask_size(new_mask_size: float) -> void:
	speed_line_color_rect.material.set_shader_parameter('mask_size', new_mask_size)

##Currently called with Keyboard but could easily do mouse controls
func _process_player_movement(delta: float) -> void:
	var input_axis := Input.get_axis("steer_up", "steer_down")
	
	if _is_changing_lanes:
		var player_global_y := player.global_position.y
		var new_lane_global_y := lane_markers_center[current_lane].global_position.y
		if is_equal_approx(player_global_y, new_lane_global_y):
			_is_changing_lanes = false
		else:
			player.global_position.y = move_toward(player_global_y, new_lane_global_y, delta * _lane_shift_speed)
			#player.global_position = player.global_position.move_toward(Vector2(player.global_position.x, lane_markers_center[current_lane].global_position.y), delta * _lane_shift_speed)
			#player.global_position.y = lerpf(player_global_y, new_lane_global_y, delta * _lane_shift_speed)
	elif not is_equal_approx(input_axis, 0.0):
		if input_axis < 0.0:
			_shift_player_up()
		else:
			_shift_player_down()

func _shift_player_up() -> void:
	#can't move above top lane
	if current_lane == 0:
		return
	
	_change_player_lane(current_lane - 1)

func _shift_player_down() -> void:
	#can't move below bottom lane
	if current_lane == (_num_lanes - 1):
		return
	
	_change_player_lane(current_lane + 1)

func _change_player_lane(new_lane_num: int) -> void:
	current_lane = new_lane_num
	_is_changing_lanes = true

func _place_player_on_lane(lane_num: int) -> void:
	current_lane = lane_num
	player.global_position.y = lane_markers_center[lane_num].global_position.y

func _start_pull_back_cutscene() -> void:
	road_object_spawner.pause_spawning_objects()
	hud.visible = false
	_in_pullback_cutscene = true
	_pre_pull_back_speed = Global.car_speed
	Global.car_speed = 0.0
	game_scene_camera_2d.perform_camera_zoom(true)
