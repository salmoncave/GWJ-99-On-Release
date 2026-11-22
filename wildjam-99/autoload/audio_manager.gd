extends Node

##Maximum number of allowed audio player within the scene at a given time
const MAX_ACTIVE_AUDIO_PLAYERS: int = 15

##Constant-defined bus names in order to make sure that buses within the [AudioServer]
##are referenced properly and consistently. If changes to the names are desired,
##change them here first.
const MASTER_BUS_NAME: String = "Master"
const MUSIC_BUS_NAME: String = "Music"
const AMBIENCE_BUS_NAME: String = "Ambience"
const DIALOGUE_BUS_NAME: String = "Dialogue"
const SFX_BUS_NAME: String = "SFX"

##(*Set by user). Setting this either mutes or unmutes the [AudioServer]'s "Master" bus
var is_master_muted: bool = false:
	set(new_muted):
		is_master_muted = new_muted
		AudioServer.set_bus_mute(AudioServer.get_bus_index(MASTER_BUS_NAME), new_muted)

##(*Set by user). Setting this either mutes or unmutes the [AudioServer]'s "Music" bus
var is_music_muted: bool = false:
	set(new_muted):
		is_music_muted = new_muted
		AudioServer.set_bus_mute(AudioServer.get_bus_index(MUSIC_BUS_NAME), new_muted)

##(*Set by user). Setting this either mutes or unmutes the [AudioServer]'s "Ambience" bus
var is_ambience_muted: bool = false:
	set(new_muted):
		is_ambience_muted = new_muted
		AudioServer.set_bus_mute(AudioServer.get_bus_index(AMBIENCE_BUS_NAME), new_muted)

##(*Set by user). Setting this either mutes or unmutes the [AudioServer]'s "Dialogue" bus
var is_dialogue_muted: bool = false:
	set(new_muted):
		is_dialogue_muted = new_muted
		AudioServer.set_bus_mute(AudioServer.get_bus_index(DIALOGUE_BUS_NAME), new_muted)

##(*Set by user). Setting this either mutes or unmutes the [AudioServer]'s "SFX" bus
var is_sfx_muted: bool = false:
	set(new_muted):
		is_sfx_muted = new_muted
		AudioServer.set_bus_mute(AudioServer.get_bus_index(SFX_BUS_NAME), new_muted)

##(*Set by user). Setting this sets the [AudioServer]'s "Master" bus volume
var master_volume_db: float = 0.0:
	set(new_volume):
		master_volume_db = new_volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MASTER_BUS_NAME), new_volume)

##(*Set by user). Setting this sets the [AudioServer]'s "Music" bus volume
var music_volume_db: float = 0.0:
	set(new_volume):
		music_volume_db = new_volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS_NAME), new_volume)

##(*Set by user). Setting this sets the [AudioServer]'s "Ambience" bus volume
var ambience_volume_db: float = 0.0:
	set(new_volume):
		ambience_volume_db = new_volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(AMBIENCE_BUS_NAME), new_volume)

##(*Set by user). Setting this sets the [AudioServer]'s "Dialogue" bus volume
var dialogue_volume_db: float = 0.0:
	set(new_volume):
		dialogue_volume_db = new_volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(DIALOGUE_BUS_NAME), new_volume)

##(*Set by user). Setting this sets the [AudioServer]'s "SFX" bus volume
var sfx_volume_db: float = 0.0:
	set(new_volume):
		sfx_volume_db = new_volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS_NAME), new_volume)

##Current music stream, only one music track is intended to be accurate at a time.
var _music_stream_player: AudioStreamPlayer
##Ambient sound player as no more than one ambient sound needed at a time
var _ambience_stream_player: AudioStreamPlayer
##Sounds for the dialogue, only one dialogue sound should be active at a time.[br]
##Separating ensures that it will overwrite a new sound when it is called multiple times
var _dialogue_stream_player: AudioStreamPlayer

##All sound effects active in the game, used to dictate what sounds are active using [member MAX_ACTIVE_AUDIO_PLAYERS]
var _sound_effects_streams: Array[Node]

##Sets persistent streams when the game loads to separate them from other[br]
##dynamically spawned audio sources
func _enter_tree() -> void:
	_validate_or_generate_bus_name(MASTER_BUS_NAME)
	_validate_or_generate_bus_name(MUSIC_BUS_NAME)
	_validate_or_generate_bus_name(AMBIENCE_BUS_NAME)
	_validate_or_generate_bus_name(DIALOGUE_BUS_NAME)
	_validate_or_generate_bus_name(SFX_BUS_NAME)
	
	#Essentially just reads editor input, but could also be useful for loading. Currently ensures that
	#options sliders load in at the correct location if saved. Can be removed if unecessary
	master_volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(MASTER_BUS_NAME))
	music_volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS_NAME))
	ambience_volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(AMBIENCE_BUS_NAME))
	dialogue_volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(DIALOGUE_BUS_NAME))
	sfx_volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(SFX_BUS_NAME))
	
	#instantiate new music stream
	_music_stream_player = AudioStreamPlayer.new()
	_music_stream_player.bus = MUSIC_BUS_NAME
	_music_stream_player.name = MUSIC_BUS_NAME.to_lower().capitalize()
	add_child(_music_stream_player)
	#instantiate new ambient stream
	_ambience_stream_player = AudioStreamPlayer.new()
	_ambience_stream_player.bus = AMBIENCE_BUS_NAME
	_ambience_stream_player.name = AMBIENCE_BUS_NAME.to_lower().capitalize()
	add_child(_ambience_stream_player)
	#instantiate new gui stream
	_dialogue_stream_player = AudioStreamPlayer.new()
	_dialogue_stream_player.bus = DIALOGUE_BUS_NAME
	_dialogue_stream_player.name = DIALOGUE_BUS_NAME.to_lower().capitalize()
	add_child(_dialogue_stream_player)

func _fade_in_stream_player_volume(stream_player: AudioStreamPlayer, fade_in_volume_db: float, fade_duration_seconds: float = 1.0) -> void:
	var fade_tween := create_tween()
	fade_tween.tween_property(stream_player, "volume_db", fade_in_volume_db, fade_duration_seconds)

func _fade_out_stream_player_volume(stream_player: AudioStreamPlayer, fade_duration_seconds: float = 1.0) -> void:
	#Apparently zero volume just goes to NaN when in linear, so this is essentially
	#zero volume, and we still have to tween down the db instead of the linear volume
	var zero_volume: float = linear_to_db(0.001)
	var fade_tween := create_tween()
	fade_tween.tween_property(stream_player, "volume_db", zero_volume, fade_duration_seconds)

## - Fades out and in a specific [AudioStreamPlayer] for more seamless audio by doing the following:
## - Tweening down the volume from [AudioStreamPlayer] specified[br]
## - swapping over to the new [AudioStream][br]
## - Tweening the volume back up[br]
func _fade_out_and_in_stream_player(stream_player: AudioStreamPlayer, stream: AudioStream, total_duration_seconds: float = 2.0) -> void:
	var step_duration_seconds := total_duration_seconds/2
	
	var original_volume_db = stream_player.volume_db
	
	if stream_player.stream != null and stream_player.playing:
		_fade_out_stream_player_volume(stream_player, step_duration_seconds)
		await get_tree().create_timer(step_duration_seconds).timeout
	
	stream_player.stream = stream
	stream_player.play()
	
	_fade_in_stream_player_volume(stream_player, original_volume_db, step_duration_seconds)

##Ensures that the [AudioManager] will always have the buses the it is looking for[br]
##NOTE: This CAN overwrite intended changes to the "Audio" tab in the inspector if the[br]
##correct bus names are not supplied. Ensure that your streams are assinged to the intended bus
func _validate_or_generate_bus_name(bus_name: String) -> void:
	#AudioServer returns -1 when the bus name does not exist within its list
	if AudioServer.get_bus_index(bus_name) == -1:
		#Get the current size which is one larger than the last index in the array
		var current_audio_bus_size = AudioServer.bus_count
		#Add a new bus there and rename it
		AudioServer.add_bus(current_audio_bus_size)
		AudioServer.set_bus_name(current_audio_bus_size, bus_name)

##Starts a new ambient stream in the background using [method _fade_out_and_in_stream_player][br]
##Will just fade in if there's no previous ambient stream
func set_new_ambient_track(new_ambient_stream: AudioStream) -> void:
	_fade_out_and_in_stream_player(_ambience_stream_player, new_ambient_stream)

##Starts a new music track in the background using [method _fade_out_and_in_stream_player][br]
##Will just fade in if there was no previous music stream
func set_new_music_track(new_music_stream: AudioStream, _fade_duration: float = 2.0) -> void:
	_fade_out_and_in_stream_player(_music_stream_player, new_music_stream, _fade_duration)

##Public method for spawning a new sound emitter at a location, the sound[br]
##NOTE: Audio may be removed by system over time, so expect unpredictable results[br]
##Method for creating new audio emitters when sounds are added to the manager[br]
##If the max number of instances is exceeded, the audio player will
##hijack the oldest exisiting emitter instead
func spawn_sound_emitter(
	sound: AudioStream, _location = null, _volume_db: float = 0.0,
	 _pitch_min: float = 0.95, _pitch_max: float = 1.05):
	#Quick return statement to ignore any call made while the sfx was muted. This can be disabled
	#if it produces unpredictable results with persistent sounds, but it will save performance
	#otherwise
	if is_master_muted or is_sfx_muted: return
	
	var new_audio_emitter: Node
	
	if _location is Vector2 or _location is Vector2i:
		var emitter_location: Vector2 = _location as Vector2
		new_audio_emitter = AudioStreamPlayer2D.new()
		new_audio_emitter.position = emitter_location
	elif _location is Vector3 or _location is Vector3i:
		var emitter_location: Vector3 = _location as Vector3
		new_audio_emitter = AudioStreamPlayer3D.new()
		new_audio_emitter.position = emitter_location
	else:
		new_audio_emitter = AudioStreamPlayer.new()
	add_child(new_audio_emitter)
	_sound_effects_streams.append(new_audio_emitter)
	new_audio_emitter.bus = SFX_BUS_NAME
	new_audio_emitter.stream = sound
	new_audio_emitter.volume_db = _volume_db
	var randomized_pitch_scale: float = randf_range(_pitch_min, _pitch_max)
	clampf(randomized_pitch_scale, 0.5, 1.5)
	new_audio_emitter.pitch_scale = randomized_pitch_scale
	new_audio_emitter.play()
	
	new_audio_emitter.finished.connect(func() -> void:
		_sound_effects_streams.erase(new_audio_emitter)
		new_audio_emitter.queue_free()
	)
	
	if _sound_effects_streams.size() > MAX_ACTIVE_AUDIO_PLAYERS:
		var last_sound_index = _sound_effects_streams.front() as Node
		if last_sound_index.has_method("stop"):
			last_sound_index.stop()
		else:
			last_sound_index.queue_free()
	
##Plays the current music track if stopped. Only intended for use if the [member _music_stream_player]
##is already stopped. If looking to set a new music track, use [method set_new_music_track]
func play_music() -> void:
	_music_stream_player.play()

##Stops the current music track manually. If the track will be used again shortly thereafter,
##use [method pause_music] instead.
func stop_music() -> void:
	_music_stream_player.stop()

##Pauses the current music track without stopping it
func pause_music() -> void:
	_music_stream_player.stream_paused = true

##Unpauses the current music track without stopping it
func unpause_music() -> void:
	_music_stream_player.stream_paused = false

##Plays the current ambient track if stopped. Only intended for use if the [member _ambience_stream_player]
##is already stopped. If looking to set a new ambient track, use [method set_new_ambient_track]
func play_ambience() -> void:
	_ambience_stream_player.play()

##Stops the current ambient track manually. If the track will be used again shortly thereafter,
##use [method pause_ambience] instead.
func stop_ambience() -> void:
	_ambience_stream_player.stop()

##Pauses the current music track without stopping it
func pause_ambience() -> void:
	_ambience_stream_player.stream_paused = true

##Unpauses the current music track without stopping it
func unpause_ambience() -> void:
	_ambience_stream_player.stream_paused = false
