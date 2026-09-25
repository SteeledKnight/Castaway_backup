extends Node

const DUST = preload("uid://c5hivpqt66pe8")
const BLOOD = preload("uid://dxnqnlcxtu60x")
const HIT_PARTICLES = preload("uid://dkhex1f7evklp")

signal camera_shook(strength)

func hit_particles(pos : Vector3, dir : float, settings : HitParticleSettings = null) -> void:
	var p : HitParticles = HIT_PARTICLES.instantiate()
	add_child(p)
	p.global_position = pos
	p.start(dir, settings)

func spawn_dust( pos : Vector3 ) -> GPUParticles3D:
	var dust := DUST.instantiate()
	add_child(dust)
	dust.global_position = pos
	return dust

func blood_splat(pos : Vector3) -> GPUParticles3D:
	var blood := BLOOD.instantiate()
	add_child(blood)
	blood.global_position = pos
	return blood

func camera_shake(strength : float = 0.3) -> void:
	camera_shook.emit(strength)
