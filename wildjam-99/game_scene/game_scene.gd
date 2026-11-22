class_name GameScene extends Node

const DEFAULT_LANE_SHIFT_SPEED := 300.0

@export var player: PlayerCar = null
@export var explosion_particles: PackedScene
@export var explosion_particles_small: PackedScene
@export var lane_markers_center: Array[Marker2D] = []
@export var gear_texture: Texture2D

@onready var game_scene_camera_2d: GameSceneCamera2D = %GameSceneCamera2D
@onready var speed_line_color_rect: ColorRect = %SpeedLineColorRect
@onready var traffic_light: TrafficLight = %TrafficLight
@onready var hud: GameHUD = %Hud
@onready var road_object_spawner: RoadObjectSpawner = %RoadObjectSpawner
@onready var spacebar_animated_sprite_2d: AnimatedSprite2D = %SpacebarAnimatedSprite2D
@onready var fade_color_rect: ColorRect = %FadeColorRect

var current_lane: int = 0
var _num_lanes: int = 4
var _lane_shift_speed: float = 300.0

var _is_changing_lanes: bool = false
var _in_pullback_cutscene: bool = false
var _is_pulling_back_car: bool = false
var _can_pull_back_car: bool = false
var _has_lost: bool = false

var _pre_pull_back_speed: float = 0.0
#var _pre_pull_player_x: float = 0.0
var _max_pull_back_deviation_x: float = 100.0
var _pull_back_speed: float = 200.0
#var _stored_launch_force: float = 0.0
#var _launch_speed_stage: int = 0
var _launch_speed_stage_multipler := [0.8, 1.0, 1.2, 0.8]

var _speed_line_tween: Tween

var gears: int = 0:
	set(value):
		gears = clampi(value, 0, 3)

func _ready() -> void:
	gears = Global.starting_gears
	
	_toggle_road_lines(Global.road_lines)
	SignalBus.road_lines_toggled.connect(
		_toggle_road_lines
	)
	
	_place_player_on_lane(0)
	
	var tween := create_tween()
	tween.tween_property(fade_color_rect, "modulate:a", 0.0, 0.75)
	
	_start_pull_back_cutscene()
	
	_lane_shift_speed = DEFAULT_LANE_SHIFT_SPEED
	hud.gear_texture_progress_bar.value = gears
	
	SignalBus.spawn_temporary_speed_lines.connect(
		_tween_temporary_speed_lines.bind(true)
	)
	
	SignalBus.car_speed_updated.connect(
		_on_signal_bus_car_speed_updated
	)
	
	road_object_spawner.player_collided_with_road_object.connect(
		_on_player_collided_with_road_object
	)

func _toggle_road_lines(toggle: bool) -> void:
	$ParallaxLayers/RoadParallax.visible = toggle

func _tween_gear_spent() -> void:
	var gear_tween := create_tween()
	var tween_duration := 0.30
	var tween_offset := Vector2(0.0, -96.0)
	
	var gear_sprite := _create_gear_sprite(false)
	gear_sprite.z_index = player.z_index - 1
	gear_sprite.global_position = player.global_position + Vector2(0.0, -200.0)
	gear_sprite.scale = Vector2.ONE * 0.5
	gear_sprite.visible = true
	
	var offset_position := player.global_position + tween_offset
	
	gear_tween.tween_property(gear_sprite, "rotation_degrees", 360.0, tween_duration * 2.0)
	gear_tween.parallel().tween_property(gear_sprite, "global_position", offset_position, tween_duration)
	gear_tween.tween_property(gear_sprite, "global_position", player.global_position, tween_duration)
	
	await gear_tween.finished
	
	var _explosion_particles := explosion_particles_small.instantiate() as GPUParticles2D
	_explosion_particles.global_position = player.global_position
	add_child(_explosion_particles)
	_explosion_particles.z_index = 10
	_explosion_particles.emitting = true
	
	gear_sprite.queue_free()
	
	_can_pull_back_car = true
	_enable_spacebar_sprite()

func _player_collected_gear(collect_position: Vector2) -> void:
	if gears > 2:
		return
	
	var tween_destination: Vector2
	
	var gear_sprite := _create_gear_sprite(false)
	gear_sprite.global_position = collect_position
	
	tween_destination = _get_current_global_gear_position_from_hud()
	var gear_tween := create_tween()
	var tween_duration := 0.5
	var collect_offset := Vector2(0.0, -64.0)
	
	gears += 1
	
	gear_sprite.visible = true
	
	gear_tween.tween_property(gear_sprite, "global_position", collect_position + collect_offset, tween_duration * 0.5)
	gear_tween.tween_property(gear_sprite, "global_position", tween_destination, tween_duration).set_delay(0.5)
	
	await gear_tween.finished
	
	gear_sprite.visible = false
	gear_sprite.queue_free()
	hud.gear_texture_progress_bar.value = gears

func _physics_process(delta: float) -> void:
	if _has_lost:
		return
	#if Input.is_action_just_pressed("debug_00"):
		#_start_pull_back_cutscene()
	
	if _in_pullback_cutscene:
		if Input.is_action_just_pressed("pull_back") and _can_pull_back_car and not _is_pulling_back_car:
			_start_pull_back()
			spacebar_animated_sprite_2d.pause()
			spacebar_animated_sprite_2d.frame = 5
		elif _is_pulling_back_car:
			_process_pull_back(delta)
		
		return
	
	_process_player_movement(delta)

func _on_player_collided_with_road_object(road_object: RoadObject) -> void:
	if road_object.hazardous:
		if gears <= 0:
			_player_lost(road_object)
			return
		else:
			gears -= 1
			hud.gear_texture_progress_bar.value = gears
		
	if road_object is RoadObjectCar:
		_player_collided_with_car(road_object)
	elif road_object is RoadObjectGear:
		_player_collected_gear(road_object.global_position)
	elif road_object is RoadObjectSlowdown:
		_player_collided_with_slowdown_object(road_object)

func _spawn_explosion_vfx(_custom_spawn_position: Vector2 = Vector2.ZERO) -> void:
	var _explosion_particles := explosion_particles.instantiate() as GPUParticles2D
	if _custom_spawn_position != Vector2.ZERO:
		_explosion_particles.global_position = _custom_spawn_position
	else:
		_explosion_particles.global_position = player.global_position
	add_child(_explosion_particles)
	_explosion_particles.emitting = true

func _player_collided_with_slowdown_object(slowdown_object: RoadObject) -> void:
	_spawn_explosion_vfx(slowdown_object.global_position)
	slowdown_object.queue_free()
	
	var slowdown_multiplier := 0.8
	Global.car_speed = clampf(roundf(Global.car_speed * slowdown_multiplier), 200.0, Global.CAR_MAX_SPEED)

func _player_collided_with_car(collided_car: RoadObjectCar) -> void:
	_spawn_explosion_vfx()
	
	player.visible = false
	collided_car.global_position.x = player.global_position.x
	player.global_position.y = collided_car.global_position.y
	player.car_sprite.texture = collided_car.object_sprite_2d.texture
	current_lane = collided_car.lane
	
	player.visible = true
	collided_car.visible = false
	collided_car.queue_free()
	
	_start_pull_back_cutscene(true)

func _player_lost(road_object: RoadObject) -> void:
	_pause_global_car_speed()
	_has_lost = true
	await game_scene_camera_2d.perform_camera_zoom(true).finished
	
	_spawn_explosion_vfx()
	road_object.visible = false
	player.visible = false
	hud.show_game_over_panel()
	await get_tree().create_timer(0.25).timeout
	_spawn_explosion_vfx(player.global_position + Vector2(64.0, -64.0))
	await get_tree().create_timer(0.25).timeout
	_spawn_explosion_vfx(player.global_position + Vector2(-64.0, -64.0))

func _on_signal_bus_car_speed_updated(new_speed: float) -> void:
	_lane_shift_speed = clampf(DEFAULT_LANE_SHIFT_SPEED + (new_speed / 10.0), DEFAULT_LANE_SHIFT_SPEED, 550.0)

func _start_pull_back() -> void:
	#_pre_pull_player_x = player.global_position.x
	traffic_light.place_light_above_player(player)
	traffic_light.enable_traffic_light()
	traffic_light.start_traffic_light()
	_can_pull_back_car = false
	_is_pulling_back_car = true

##Do spacebar first and add mouse later
##Pull back to extent, time it release with green light
##Multiplier for each color stage they waited I guess
func _process_pull_back(delta: float) -> void:
	if traffic_light.current_stage >= 2 and spacebar_animated_sprite_2d.frame != 0:
		spacebar_animated_sprite_2d.frame = 0
	if traffic_light.current_stage == 3 or Input.is_action_just_released("pull_back"):
		_launch_car(_pre_pull_back_speed)
	elif Input.is_action_pressed("pull_back"):
		player.car_sprite.position.x = clampf(
			player.car_sprite.position.x - (_pull_back_speed * delta), - _max_pull_back_deviation_x, 0.0)

		#_launch_car(_pre_pull_back_speed * _launch_speed_stage_multipler[_launch_speed_stage])

func _launch_car(launch_force: float) -> void:
	spacebar_animated_sprite_2d.visible = false
	
	var tween_duration := 50.0 / launch_force
	var release_tween := create_tween()
	#var starting_mask_size := 1.0
	#var ending_mask_size := 0.1
	
	_tween_temporary_speed_lines(false)
	game_scene_camera_2d.perform_camera_zoom(false)
	
	release_tween.set_parallel(true)
	release_tween.tween_property(player.car_sprite, "position", Vector2.ZERO, tween_duration)
	await release_tween.finished
	
	_in_pullback_cutscene = false
	_is_pulling_back_car = false
	
	traffic_light.stop_traffic_light()
	
	Global.car_speed = roundf(launch_force * _launch_speed_stage_multipler[traffic_light.current_stage])
	
	traffic_light.disable_traffic_light()
	hud.visible = true
	road_object_spawner.resume_spawning_objects()
	Global.launches += 1

func _tween_temporary_speed_lines(short: bool) -> void:
	var starting_mask_size := 1.0
	var ending_mask_size := 0.1
	var initial_tween_duration := 0.25
	var lines_on_screen_duration := 1.0 if short else 2.0
	var fade_away_duration := 2.0 if short else 5.0
	
	if _speed_line_tween and _speed_line_tween.is_running():
		_speed_line_tween.stop()
	
	_speed_line_tween = create_tween()
	
	_set_speed_line_mask_size(starting_mask_size)
	
	speed_line_color_rect.visible = true
	
	_speed_line_tween.tween_method(
		_set_speed_line_mask_size, starting_mask_size, ending_mask_size, initial_tween_duration
		)
	
	_speed_line_tween.tween_method(
		_set_speed_line_mask_size, ending_mask_size, starting_mask_size, fade_away_duration
		).set_delay(lines_on_screen_duration)
	
	await _speed_line_tween.finished
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

func _start_pull_back_cutscene(_show_gear: bool = false) -> void:
	road_object_spawner.pause_spawning_objects()
	hud.visible = false
	_in_pullback_cutscene = true
	_pause_global_car_speed()
	await game_scene_camera_2d.perform_camera_zoom(true).finished
	if _show_gear:
		hud.gear_texture_progress_bar.value = gears
		_tween_gear_spent()
	else:
		_can_pull_back_car = true
		_enable_spacebar_sprite()

func _enable_spacebar_sprite() -> void:
	var spacebar_offset := Vector2(0.0, 32.0)
	spacebar_animated_sprite_2d.global_position = player.global_position + spacebar_offset
	spacebar_animated_sprite_2d.visible = true
	spacebar_animated_sprite_2d.play('default')

func _pause_global_car_speed() -> void:
	_pre_pull_back_speed = Global.car_speed
	Global.car_speed = 0.0

func _create_gear_sprite(spawn_visible: bool) -> Sprite2D:
	var gear_sprite := Sprite2D.new()
	gear_sprite.visible = spawn_visible
	gear_sprite.texture = gear_texture
	gear_sprite.z_index = 10
	add_child(gear_sprite)
	
	return gear_sprite

func _get_current_global_gear_position_from_hud() -> Vector2:
	return (get_viewport().get_visible_rect().size * -0.5) + hud.gear_markers[gears].global_position
