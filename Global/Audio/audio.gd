extends Node

enum REVERB {NONE, SMALL, MEDIUM, LARGE}

@export var ui_focus_audio : AudioStream
@export var ui_select_audio : AudioStream
@export var ui_cancel_audio : AudioStream
@export var ui_success_audio : AudioStream
@export var ui_error_audio : AudioStream

var current_track : int = 0
var music_tweens : Array[Tween]
var ui_audio_player : AudioStreamPlaybackPolyphonic
var audio_pool : Array[AudioStreamPlayer3D]
var audio_index : int = 0

@onready var music_1: AudioStreamPlayer = %Music1
@onready var music_2: AudioStreamPlayer = %Music2
@onready var ui: AudioStreamPlayer = %UI


func _ready() -> void:
	ui.play()
	ui_audio_player = ui.get_stream_playback()
	for i in 32:
		var audio_player := AudioStreamPlayer3D.new()
		add_child(audio_player)
		audio_player.bus = "SFX"
		audio_pool.append(audio_player)

func play_music(audio : AudioStream) -> void:
	var current_player : AudioStreamPlayer = get_music_player(current_track)
	if current_player.stream == audio:
		return
	
	var next_track : int = wrapi(current_track + 1, 0, 2)
	var next_player : AudioStreamPlayer = get_music_player(next_track)
	
	next_player.stream = audio
	next_player.play()
	
	for t in music_tweens:
		t.kill()
	
	music_tweens.clear()
	fade_out(current_player)
	fade_in(next_player)
	
	current_track = next_track

func play_spatial_sound(audio : AudioStream, pos : Vector3, ignore_pool : bool = false) -> void:
	if ignore_pool:
		var sp_player := AudioStreamPlayer3D.new()
		add_child(sp_player)
		sp_player.bus = "SFX"
		sp_player.global_position = pos
		sp_player.stream = audio
		sp_player.finished.connect(sp_player.queue_free)
		sp_player.play()
	else:
		var sp_player := audio_pool[audio_index]
		sp_player.global_position = pos
		sp_player.stream = audio
		sp_player.play()
		audio_index = wrapi(audio_index + 1, 0, 32)

func get_music_player(i : int) -> AudioStreamPlayer:
	if i == 0:
		return music_1
	else:
		return music_2

func fade_out(player : AudioStreamPlayer) -> void:
	var tween := create_tween()
	music_tweens.append(tween)
	tween.tween_property(player, "volume_linear", 0.0, 1.0)
	tween.tween_callback(player.stop)

func fade_in(player : AudioStreamPlayer) -> void:
	var tween := create_tween()
	music_tweens.append(tween)
	tween.tween_property(player, "volume_linear", 1.0, 1.0)

func set_reverb(_type : REVERB) -> void:
	pass

func setup_button_audio(node : Node) -> void:
	for c in node.find_children("*", "Button"):
		c.pressed.connect(ui_select)
		c.focus_entered.connect(ui_focus)

func play_ui_audio(audio : AudioStream) -> void:
	if ui_audio_player:
		ui_audio_player.play_stream(audio)

#region // UI subroutines
func ui_focus() -> void:
	play_ui_audio(ui_focus_audio)

func ui_select() -> void:
	play_ui_audio(ui_select_audio)

func ui_cancel() -> void:
	play_ui_audio(ui_cancel_audio)

func ui_success() -> void:
	play_ui_audio(ui_success_audio)

func ui_error() -> void:
	play_ui_audio(ui_error_audio)
#endregion
