@icon("uid://ckket1s38e0ke")
class_name Switch extends Node3D

signal activated

@export var switch_audio : AudioStream = preload("uid://beb0hdjne0tuu")
## i.e. not a foot switch/pressure plate
@export var interact_required : bool = true

var open : bool = false
var door = null

@onready var detector: Area3D = $Detector


func _ready() -> void:
	if SaveManager.persistent_data.get_or_add(unique_name(), "closed") ==  "open":
		set_open()
	else:
		detector.body_entered.connect(_on_player_entered)
		detector.body_exited.connect(_on_player_exited)

func _on_player_entered(_p : Player) -> void:
	if interact_required:
		SignalBus.player_interacted.connect(_player_interacted)
	else:
		#wait and press
		pass

func _on_player_exited(_p : Player) -> void:
	if interact_required:
		SignalBus.player_interacted.disconnect(_player_interacted)

func _player_interacted(_p : Player) -> void:
	#open door
	Audio.play_spatial_sound(switch_audio, global_position)
	SaveManager.persistent_data[unique_name()] = "open"
	activated.emit()
	set_open()
	pass

func set_open() -> void:
	#control collisions and movement with animation player (resources?)
	open = true
	detector.queue_free()
	pass

func unique_name() -> String:
	var u_name := ResourceUID.path_to_uid(owner.scene_file_path)
	u_name += "_" + door.name + "_" + name
	return u_name

func is_open() -> bool:
	return open
