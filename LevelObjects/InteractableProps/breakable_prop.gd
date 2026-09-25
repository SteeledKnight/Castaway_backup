@tool
@icon("uid://ev556rw76vdt")
class_name BreakableProp extends Node3D

@warning_ignore("unused_signal")
signal destroyed
signal damage_taken

#TODO: setup method to store persistent state
@export var persistent_state : bool = false

@export_category("Damage")
@export var hp : float = 3.0
##-1 = disabled
@export var fixed_hit_count : int = -1

@export_category("Particles")
@export var emission_offset := Vector3.ZERO
@export var hit_particles : Array[HitParticleSettings]
@export var destroy_particles : Array[HitParticleSettings]

@export_category("Audio")
#TODO: set defaults when I have 'final'-ish sfx
@export var hit_audio : AudioStream
@export var destroy_audio : AudioStream

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	for c in get_children():
		if c is Hitbox:
			c.damaged.connect(_on_damaged)

func _on_damaged(attackbox : Attackbox) -> void:
	if fixed_hit_count > 0:
		fixed_hit_count -= 1
		if hit_audio:
			Audio.play_spatial_sound(hit_audio, global_position)
	elif hp > 0.0:
		damage_taken.emit()
		hp -= attackbox.damage
		if hit_audio:
			Audio.play_spatial_sound(hit_audio, global_position)
	if fixed_hit_count == 0 or hp <= 0.0:
		destroyed.emit()
		for p in destroy_particles:
			VfxManager.hit_particles(global_position, 0.0, p)
		if destroy_audio:
			Audio.play_spatial_sound(destroy_audio, global_position)
		#Handle dropping items or whatever
		call_deferred("queue_free")

func _get_configuration_warnings() -> PackedStringArray:
	if !_check_for_hitbox():
		return ["Requires a Hitbox"]
	else:
		return []

func _check_for_hitbox() -> bool:
	for c in get_children():
		if c is Hitbox:
			return true
	return false
