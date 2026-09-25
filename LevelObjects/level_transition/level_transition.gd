@tool
@icon("uid://d4la45bxf6kjv")
class_name LevelTransition extends Node3D

enum SIDE {LEFT, RIGHT, TOP, BOTTOM}

@export_range(1, 8, 1, "or_greater") var size : float = 2 :
	set(value):
		size = value
		apply_area_settings()

@export var location := SIDE.LEFT:
	set(value):
		location = value
		apply_area_settings()

@export_file("*.tscn") var target_level
@export var target_area_name : String = "LevelTransistion"

@onready var area: Area3D = $Area3D
@onready var shape: CollisionShape3D = $Area3D/CollisionShape3D


#region /// editor functions
func apply_area_settings() -> void:
	#if not Engine.is_editor_hint():
		#return
	shape = get_node_or_null("Area3D/CollisionShape3D")
	if not shape or not area:
		return
	if location == SIDE.LEFT or location == SIDE.RIGHT:
		shape.shape.size.y = size
		shape.shape.size.x = 1
		if location == SIDE.RIGHT:
			area.position.x = 0.5
		else:
			area.position.x = -0.5
		area.position.y = size / 2
	if location == SIDE.TOP or location == SIDE.BOTTOM:
		shape.shape.size.x = size
		shape.shape.size.y = 1
		if location == SIDE.TOP:
			area.position.y = 0.5
		else:
			area.position.y = -0.5
		area.position.x = size / 2
	pass
#endregion


func _ready() -> void:
	print(SIDE.keys()[location])
	if Engine.is_editor_hint():
		return
	apply_area_settings()
	SceneManager.new_scene_ready.connect(_new_scene_ready)
	SceneManager.load_scene_finished.connect(_load_scene_finished)

func get_offset(skew : float) -> Vector3:
	var offset : Vector3 = Vector3.ZERO
	
	if location == SIDE.LEFT or location == SIDE.RIGHT:
		offset.y = skew
		if location == SIDE.LEFT:
			offset.x = 0.51
		else:
			offset.x = -0.51
	if location == SIDE.TOP or location == SIDE.BOTTOM:
		offset.y = skew
		if location == SIDE.TOP:
			offset.y = 2.01
		if location == SIDE.BOTTOM:
			offset.y = 0.01
	return offset

func _player_entered(_n : Node3D) -> void:
	if _n.is_in_group("Player"):
		var skew = 0.0
		if location == SIDE.LEFT or location == SIDE.RIGHT:
			skew = _n.global_position.y - self.global_position.y
		if location == SIDE.TOP or location == SIDE.BOTTOM:
			skew = _n.global_position.x - self.global_position.x
		SceneManager.change_scene(target_level, target_area_name, skew, SIDE.keys()[location])

func _new_scene_ready(target_area, skew) -> void:
	if target_area == name:
		var player := get_tree().get_first_node_in_group("Player")
		player.global_position = global_position + get_offset(skew)
	pass

func _load_scene_finished() -> void:
	area.monitoring = false
	if not area.body_entered.is_connected(_player_entered):
		area.body_entered.connect(_player_entered)
	await get_tree().physics_frame
	await get_tree().physics_frame
	area.monitoring = true
