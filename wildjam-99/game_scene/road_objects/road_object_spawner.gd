class_name RoadObjectSpawner extends Node2D

signal player_collided_with_car(car_object: RoadObjectCar)

@export var spawn_points: Array[Marker2D]

@export var road_objects: Array[PackedScene]
@export var debug_override_object: PackedScene

var num_spawn_points: int

var last_spawned_point: Marker2D = null
var second_to_last_spawned_point: Marker2D = null

var last_spawned_road_object: PackedScene = null

@export var _spawn_interval_seconds: float = 1.5

@onready var spawn_timer: Timer = %SpawnTimer
@onready var despawn_marker_2d: Marker2D = %DespawnMarker2D

func pause_spawning_objects() -> void:
	spawn_timer.paused = true

func resume_spawning_objects() -> void:
	spawn_timer.paused = false

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
	
	if new_road_object is RoadObjectCar:
		new_road_object.player_collided_with_road_object.connect(
			player_collided_with_car.emit.bind(new_road_object)
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
	
	var chosen_road_object := _road_objects.pick_random() as PackedScene
	
	last_spawned_road_object = chosen_road_object
	
	return chosen_road_object

func _on_spawn_timer_timeout() -> void:
	spawn_new_road_object()
