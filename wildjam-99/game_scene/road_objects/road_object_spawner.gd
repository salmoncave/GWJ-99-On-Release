class_name RoadObjectSpawner extends Node2D

@export var spawn_points: Array[Marker2D]
@export var road_object: PackedScene

var num_spawn_points: int

var last_spawned_point: Marker2D = null
var second_to_last_spawned_point: Marker2D = null

var _spawn_interval_seconds: float = 2.5

@onready var spawn_timer: Timer = %SpawnTimer

func pause_spawning_objects() -> void:
	spawn_timer.paused = true

func resume_spawning_objects() -> void:
	spawn_timer.paused = false

func _ready() -> void:
	spawn_timer.wait_time = _spawn_interval_seconds
	spawn_timer.start()

func spawn_new_road_object() -> void:
	var spawn_position := get_next_spawning_lane().global_position
	
	var new_road_object := road_object.instantiate() as RoadObject
	add_child(new_road_object)
	new_road_object.global_position = spawn_position

func get_next_spawning_lane() -> Marker2D:
	var _spawn_points := spawn_points.duplicate()
	
	if last_spawned_point and _spawn_points.has(last_spawned_point):
		_spawn_points.erase(last_spawned_point)
	if second_to_last_spawned_point and _spawn_points.has(second_to_last_spawned_point):
		_spawn_points.erase(second_to_last_spawned_point)
	
	var chosen_point: Marker2D = _spawn_points.pick_random()
	
	second_to_last_spawned_point = last_spawned_point
	last_spawned_point = chosen_point
	
	return chosen_point

func _on_spawn_timer_timeout() -> void:
	spawn_new_road_object()
