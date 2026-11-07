extends Node

signal ending_finished

const TITLE_TRACK: AudioStreamWAV = preload("res://Soundtrack/title_theme.wav")
const GAMEPLAY_TRACK: AudioStreamWAV = preload("res://Soundtrack/gameplay_theme.wav")
const ENDING_TRACK: AudioStreamWAV = preload("res://Soundtrack/ending_theme.wav")

var _player: AudioStreamPlayer
var _playing_ending := false
var has_finished_ending := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player = AudioStreamPlayer.new()
	_player.name = "MusicPlayer"
	_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_player.finished.connect(_on_player_finished)
	add_child(_player)
	play_title()


func play_title() -> void:
	_play_track(TITLE_TRACK, true)


func play_gameplay() -> void:
	_play_track(GAMEPLAY_TRACK, true)


func play_ending() -> void:
	_play_track(ENDING_TRACK, false)


func _play_track(track: AudioStreamWAV, should_loop: bool) -> void:
	_player.stop()
	_playing_ending = not should_loop
	if _playing_ending:
		has_finished_ending = false

	var stream := track.duplicate() as AudioStreamWAV
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if should_loop else AudioStreamWAV.LOOP_DISABLED
	stream.loop_begin = 0
	stream.loop_end = roundi(stream.get_length() * stream.mix_rate)
	_player.stream = stream
	_player.play()


func _on_player_finished() -> void:
	if not _playing_ending:
		return

	_playing_ending = false
	has_finished_ending = true
	ending_finished.emit()
