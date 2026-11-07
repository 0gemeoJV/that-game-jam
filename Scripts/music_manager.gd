extends Node

signal ending_finished

const SOUNDTRACK: AudioStreamWAV = preload("res://Soundtrack/psychronic-clouds-of-imagination-246734.wav")
const TITLE_START := 0.0
const TITLE_END := 6.0
const GAMEPLAY_START := 7.0
const GAMEPLAY_END := 171.0
const ENDING_START := 172.0
const ENDING_END := 190.0

var _track: AudioStreamWAV
var _player: AudioStreamPlayer
var _playing_ending := false
var has_finished_ending := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_track = SOUNDTRACK.duplicate() as AudioStreamWAV
	_player = AudioStreamPlayer.new()
	_player.name = "MusicPlayer"
	_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_player.stream = _track
	add_child(_player)
	play_title()


func _process(_delta: float) -> void:
	if _playing_ending and _player.get_playback_position() >= ENDING_END:
		_player.stop()
		_playing_ending = false
		has_finished_ending = true
		ending_finished.emit()


func play_title() -> void:
	_play_loop(TITLE_START, TITLE_END)


func play_gameplay() -> void:
	_play_loop(GAMEPLAY_START, GAMEPLAY_END)


func play_ending() -> void:
	_player.stop()
	_track.loop_mode = AudioStreamWAV.LOOP_DISABLED
	_playing_ending = true
	has_finished_ending = false
	_player.play(ENDING_START)


func _play_loop(start_time: float, end_time: float) -> void:
	_player.stop()
	_playing_ending = false
	_track.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_track.loop_begin = roundi(start_time * _track.mix_rate)
	_track.loop_end = roundi(end_time * _track.mix_rate)
	_player.play(start_time)
