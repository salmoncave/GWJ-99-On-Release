class_name GameScene extends Node

@export var player: PlayerCar = null

@export var lane_markers_center: Array[Marker2D] = []

var current_lane: int = 0
var _num_lanes: int = 4
var _lane_shift_speed: float = 200.0

var _is_changing_lanes: bool = false

func _ready() -> void:
	place_player_on_lane(1)
	#pass

func _physics_process(delta: float) -> void:
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
			shift_player_up()
		else:
			shift_player_down()
	

func shift_player_up() -> void:
	#can't move above top lane
	if current_lane == 0:
		return
	
	change_player_lane(current_lane - 1)

func shift_player_down() -> void:
	#can't move below bottom lane
	if current_lane == 3:
		return
	
	change_player_lane(current_lane + 1)

func change_player_lane(new_lane_num: int) -> void:
	current_lane = new_lane_num
	_is_changing_lanes = true

func place_player_on_lane(lane_num: int) -> void:
	current_lane = lane_num
	player.global_position.y = lane_markers_center[lane_num].global_position.y
