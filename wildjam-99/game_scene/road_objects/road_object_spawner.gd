class_name RoadObjectSpawner extends Node2D

const ROAD_OBJECT_GEAR = preload("uid://3puhnv85q37w")

signal player_collided_with_road_object(road_object: RoadObject)

@export var spawn_points: Array[Marker2D]
@export var game_scene: GameScene

@export var road_objects: Array[PackedScene]
@export var debug_override_object: PackedScene

var num_spawn_points: int

var last_spawned_point: Marker2D = null
var second_to_last_spawned_point: Marker2D = null

var last_spawned_road_object: PackedScene = null

@export var _spawn_interval_seconds: float = 1.5

@onready var spawn_timer: Timer = %SpawnTimer
@onready var despawn_marker_2d: Marker2D = %DespawnMarker2D
@onready var interval_increase_timer: Timer = %IntervalIncreaseTimer


func pause_spawning_objects() -> void:
	spawn_timer.paused = true
	interval_increase_timer.paused = true

func resume_spawning_objects() -> void:
	spawn_timer.paused = false
	interval_increase_timer.paused = false

func _ready() -> void:
	spawn_timer.wait_time = _spawn_interval_seconds
	spawn_timer.start()

func spawn_new_road_object() -> void:
	var spawn_lane := _get_next_spawning_lane()
	var spawn_position := spawn_lane.global_position
	var ro_packed_scene := _get_next_road_object()
	
	if not ro_packed_scene:
		return
	
	var new_road_object := ro_packed_scene.instantiate() as RoadObject
	add_child(new_road_object)
	
	new_road_object.player_collided_with_road_object.connect(
			player_collided_with_road_object.emit.bind(new_road_object)
		)
	
	new_road_object.initialize_road_object()
	new_road_object.lane = spawn_points.find(spawn_lane)
	new_road_object.x_pos_delete = despawn_marker_2d.global_position.x
	new_road_object.global_position = spawn_position

func _get_next_spawning_lane() -> Marker2D:
	var _spawn_points := spawn_points.duplicate()
	
	if last_spawned_point and _spawn_points.has(last_spawned_point):
		_spawn_points.erase(last_spawned_point)
	if second_to_last_spawned_point and _spawn_points.has(second_to_last_spawned_point):
		_spawn_points.erase(second_to_last_spawned_point)
	
	var chosen_point: Marker2D = _spawn_points.pick_random()
	
	second_to_last_spawned_point = last_spawned_point
	last_spawned_point = chosen_point
	
	return chosen_point

func _get_next_road_object() -> PackedScene:
	if debug_override_object:
		return debug_override_object
	
	var _road_objects := road_objects.duplicate()
	
	if last_spawned_road_object:
		_road_objects.erase(last_spawned_road_object)
	
	if _road_objects.has(ROAD_OBJECT_GEAR) and game_scene.gears > 2:
		_road_objects.erase(ROAD_OBJECT_GEAR)
	
	var chosen_road_object := _road_objects.pick_random() as PackedScene
	
	last_spawned_road_object = chosen_road_object
	
	return chosen_road_object

func _on_spawn_timer_timeout() -> void:
	spawn_new_road_object()
	spawn_timer.start(_spawn_interval_seconds)


func _on_interval_increase_timer_timeout() -> void:
	_spawn_interval_seconds = clampf(_spawn_interval_seconds - 0.25, 0.5, 5.0)
	print(_spawn_interval_seconds)
