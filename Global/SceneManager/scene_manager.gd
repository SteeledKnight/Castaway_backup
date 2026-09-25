extends CanvasLayer

signal load_scene_started
signal new_scene_ready(target_area, skew)
signal load_scene_finished()

signal scene_entered(uid)

@onready var fade: Control = $Fade

var current_scene_uid : String


func _ready() -> void:
	fade.visible = false
	await get_tree().process_frame
	#load_scene_finished.emit()
	var current_scene : String = get_tree().current_scene.scene_file_path
	current_scene_uid = ResourceUID.path_to_uid(current_scene)
	scene_entered.emit(current_scene_uid)


func change_scene(target_level, target_area, skew, side) -> void:
	var fade_pos := get_fade_pos(side)
	fade.visible = true	
	load_scene_started.emit()
	
	await fade_screen(fade_pos, Vector2.ZERO)
	get_tree().paused = true
	
	get_tree().call_deferred("change_scene_to_file", target_level)
	current_scene_uid = ResourceUID.path_to_uid(target_level)
	scene_entered.emit(current_scene_uid)
	
	await get_tree().scene_changed
	new_scene_ready.emit(target_area, skew)
	
	get_tree().paused = false
	await fade_screen(Vector2.ZERO, -fade_pos)
	
	
	fade.visible = false
	load_scene_finished.emit()


func fade_screen(from : Vector2, to : Vector2) -> Signal:
	fade.position = from
	var tween : Tween = create_tween()
	tween.tween_property(fade, "position", to, 0.2)
	return tween.finished


func get_fade_pos(side) -> Vector2:
	var pos := Vector2(get_viewport().size.x * 2, get_viewport().size.y * 2)
	match side:
		"LEFT":
			pos *= Vector2(-1, 0)
		"RIGHT":
			pos *= Vector2(1, 0)
		"TOP":
			pos *= Vector2(0, -1)
		"DOWN":
			pos *= Vector2(0, 1)
	return pos
