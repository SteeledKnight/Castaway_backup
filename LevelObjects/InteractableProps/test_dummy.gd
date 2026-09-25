extends Node3D

@export var particles : Array[HitParticleSettings]
@export var wobble_angle : float = 4.0
@export var wobble_strength : float = 0.1
var wobble_count : int = 0
var tween : Tween

@onready var dummy: Node3D = $Dummy2
@onready var hitbox: Hitbox = $Hitbox


func _ready() -> void:
	hitbox.damaged.connect(_on_hit)

func _on_hit(a : Attackbox) -> void:
	var dir : float = 1.0
	if a.global_position.x > global_position.x:
		dir = -1.0
	wobble_count = 5
	wobble(dir)

func wobble(dir : float) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(
		dummy,
		"rotation_degrees",
		Vector3(0.0, 0.0, wobble_angle * wobble_count * dir),
		wobble_strength * 0.5
	)
	while wobble_count > 0:
		dir *= -1
		wobble_count -= 1
		tween.tween_property(
			dummy,
			"rotation_degrees",
			Vector3(0.0, 0.0, wobble_angle * wobble_count * dir),
			wobble_strength
		)
