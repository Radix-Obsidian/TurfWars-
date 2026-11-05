extends Node

## AudioManager for Turf Wars
## Manages BGM, SFX pool, and built-in procedural arcade sound synthesis.

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
var sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE: int = 8

var sound_cache: Dictionary = {}

func _ready() -> void:
	music_player.bus = "Master"
	add_child(music_player)

	for i in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)

	_generate_procedural_sfx()

func _generate_procedural_sfx() -> void:
	sound_cache["card_drop"] = _create_wav(440.0, 880.0, 0.12, "sine")
	sound_cache["melee_hit"] = _create_wav(160.0, 70.0, 0.14, "noise")
	sound_cache["ranged_attack"] = _create_wav(650.0, 320.0, 0.1, "triangle")
	sound_cache["tower_shot"] = _create_wav(320.0, 110.0, 0.2, "square")
	sound_cache["explosion"] = _create_wav(180.0, 45.0, 0.35, "noise")
	sound_cache["unit_death"] = _create_wav(380.0, 140.0, 0.18, "sawtooth")
	sound_cache["victory"] = _create_wav(523.0, 784.0, 0.45, "sine")
	sound_cache["defeat"] = _create_wav(280.0, 130.0, 0.5, "triangle")

func _create_wav(start_freq: float, end_freq: float, duration: float, wave_type: String) -> AudioStreamWAV:
	var sample_rate := 22050
	var sample_count := int(sample_rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(sample_count)

	for i in range(sample_count):
		var t := float(i) / float(sample_rate)
		var progress := float(i) / float(sample_count)
		var freq := lerpf(start_freq, end_freq, progress)
		var amp := 1.0 - progress
		var sample_val := 0.0

		match wave_type:
			"sine":
				sample_val = sin(TAU * freq * t) * amp
			"square":
				sample_val = (1.0 if sin(TAU * freq * t) > 0.0 else -1.0) * amp * 0.5
			"triangle":
				sample_val = (absf(fmod(t * freq, 1.0) - 0.5) * 4.0 - 1.0) * amp
			"noise":
				sample_val = randf_range(-1.0, 1.0) * amp
			_:
				sample_val = (fmod(t * freq, 1.0) * 2.0 - 1.0) * amp

		var byte_val := int(clampf((sample_val * 0.5 + 0.5) * 255.0, 0.0, 255.0))
		bytes[i] = byte_val

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = bytes
	return wav

func play_sound(sfx_name: String, pitch_variance: float = 0.05) -> void:
	if sound_cache.has(sfx_name):
		play_sfx(sound_cache[sfx_name], pitch_variance)

func play_music(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stream = stream
	music_player.volume_db = volume_db
	music_player.play()

func stop_music() -> void:
	music_player.stop()

func play_sfx(stream: AudioStream, pitch_variance: float = 0.0, volume_db: float = 0.0) -> void:
	if stream == null:
		return

	var available_player: AudioStreamPlayer = null
	for player in sfx_players:
		if not player.playing:
			available_player = player
			break

	if available_player == null:
		available_player = sfx_players[0]

	available_player.stream = stream
	available_player.volume_db = volume_db
	if pitch_variance > 0.0:
		available_player.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
	else:
		available_player.pitch_scale = 1.0
	available_player.play()
