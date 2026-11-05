extends Node

## AudioManager for Turf Wars
## Manages BGM and SFX playback with bus volume control.

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
var sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE: int = 8

func _ready() -> void:
	music_player.bus = "Master"
	add_child(music_player)

	for i in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)

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
