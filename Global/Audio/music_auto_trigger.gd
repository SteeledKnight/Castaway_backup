@icon("uid://y65vbtfp6rgb")
class_name MusicAutoTrigger extends Node

@export var track : AudioStream
@export var reverb : Audio.REVERB = Audio.REVERB.NONE


func _ready() -> void:
	Audio.play_music(track)
	Audio.set_reverb(reverb)
