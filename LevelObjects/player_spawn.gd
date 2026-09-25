@icon("uid://6rmyiancnovd")
class_name PlayerSpawn extends Node3D

func _ready() -> void:
	visible = false
	await get_tree().process_frame
	if get_tree().get_first_node_in_group("Player"):
		return
	
	var player : Player = load("uid://kpug08bi18j5").instantiate()
	get_tree().root.add_child(player)
	
	player.global_position = global_position
	
	if Engine.is_editor_hint():
		pass
		
