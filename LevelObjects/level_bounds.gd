@tool
@icon("uid://cmrottpi7uhk6")
class_name LevelBounds extends Area3D

@export_range(8, 1000, 1, "suffix:m") var width : float:
	set = _on_width_change
@export_range(4, 500, 1, "suffix:m")  var height : float:
	set = _on_height_change

@onready var shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	await get_tree().process_frame
	if Engine.is_editor_hint():
		visible = true
	else:
		visible = false
	
	var camera : Camera3D = null
	
	while not camera or not get_viewport():
		await get_tree().process_frame
		if get_viewport():
			camera = get_viewport().get_camera_3d()

#TODO: draw debug

func _on_width_change(value) -> void:
	if not Engine.is_editor_hint():
		return
	width = value
	if shape:
		shape.shape.size.x = value
		shape.shape.size.z = 6
		shape.position.z = 0

func _on_height_change(value) -> void:
	if not Engine.is_editor_hint():
		return
	height = value
	if shape:
		shape.shape.size.y = value
		shape.shape.size.z = 6
		shape.position.z = 0
