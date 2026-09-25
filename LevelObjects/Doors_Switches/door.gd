@tool
@icon("uid://blsun3hn7748")
class_name Door extends Node3D

@export var door_audio : AudioStream = preload("uid://yf2gksn37js1")
@export var linked_switch : Node3D :
	set(value):
		linked_switch = value
		_get_configuration_warnings()
		update_configuration_warnings()

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if linked_switch is Switch:
		linked_switch.activated.connect(_switch_activated)
		linked_switch.door = self
		call_deferred("_check_open")
	#safety to handle door able to run during scene transition
	#then pauseable afterward
	self.process_mode = Node.PROCESS_MODE_INHERIT

func _switch_activated() -> void:
	Audio.play_spatial_sound(door_audio, global_position)
	animation_player.play("door_open")
	pass

func _check_open() -> void:
	if linked_switch.is_open():
		_door_is_open()

func _door_is_open() -> void:
	print("opening")
	animation_player.play("opened")
	pass

func _get_configuration_warnings() -> PackedStringArray:
	if _check_for_switch() == false:
		return ["Requires a Switch node."]
	else:
		return []

func _check_for_switch() -> bool:
	if linked_switch is Switch:
		return true
	else:
		return false
		
