@tool
@icon("uid://bqjko8y1tqkos")
class_name Hitbox extends Area3D

signal damaged(attack)
@export var default_invulnerable_time : float = 0.5
@export var audio : AudioStream


func take_damage(attack : Attackbox) -> void:
	damaged.emit(attack)
	#TODO: calculate collision point
	VfxManager.blood_splat(Tools.get_area_center(self))
	#var dir = 1.0
	#if attack.global_position.x > global_position.x:
		#dir = -1.0
	#VfxManager.hit_particles(Tools.get_area_center(self), dir)
	if default_invulnerable_time != 0.0:
		start_invulnerable_time()
	if audio:
		Audio.play_spatial_sound(audio, global_position)

func start_invulnerable_time(duration : float = default_invulnerable_time) -> void:
	set_deferred("monitorable", false)
	await get_tree().create_timer(duration).timeout
	set_deferred("monitorable", true)

func _set(property: StringName, _value: Variant) -> bool:
	match property:
		"collision_layer", "collision_mask":
			update_configuration_warnings()
	return false  # false = let the engine still apply the value normally

func _get_configuration_warnings() -> PackedStringArray:
	if get_collision_layer_value(1) or collision_layer == 0:
		return ["Set collision to proper hitbox layer"]
	else:
		return []
