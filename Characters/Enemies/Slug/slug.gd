@icon("uid://chm0dp3xvhek3")
class_name Slug extends CharacterBody3D

@export var health : float = 3
@export var move_speed : float = .5
@export_enum("Left", "Right") var starting_direction = "Right"
@export var death_sound : AudioStream

var dir : float = 1.0
var move_tween : Tween
var knock_tween : Tween

@onready var mesh: Node3D = $Mesh
@onready var hazard_area: HazardArea = $HazardArea
@onready var hitbox: Hitbox = $Hitbox
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var edge_detector: EdgeDetector = %EdgeDetector


func _ready() -> void:
	animation_player.play("walk")
	animation_player.animation_finished.connect(_on_anim_finished)
	edge_detector.edge_detected.connect(_on_edge_detected)
	if starting_direction == "Left":
		change_dir()
	hitbox.damaged.connect(_on_damaged)
	

func _physics_process(delta: float) -> void:
	if is_on_wall():
		change_dir()
	velocity += get_gravity() * delta
	velocity.x = dir * move_speed
	move_and_slide()

func change_dir() -> void:
	dir *= -1.0
	
	if move_tween:
		move_tween.kill()
	move_tween = create_tween()
	move_tween.set_parallel(true)
	
	var target_rotation_y := 0.0 if dir > 0 else -PI  # 180 degrees in radians
	move_tween.tween_property(mesh, "rotation:y", target_rotation_y, 0.5)
	move_tween.tween_property(self, "velocity:x", dir * move_speed, 0.5)

func knockback(pos : Vector3) -> void:
	#TODO: test knockback
	var new_dir := 0.0
	var old_dir := dir
	if pos.x > global_position.x:
		new_dir = -2.5
	else:
		new_dir = 2.5
	
	dir = new_dir
	
	if knock_tween:
		knock_tween.kill()
	knock_tween = create_tween()
	knock_tween.tween_property(self, "dir", old_dir, 0.3)

func _on_edge_detected() -> void:
	if is_on_floor():
		change_dir()

func _on_damaged(attackbox : Attackbox) -> void:
	health -= attackbox.damage
	knockback(attackbox.global_position)
	
	if health > 0:
		animation_player.play("stun")
	else:
		velocity.x = 0.0
		animation_player.play("death")
		if death_sound:
			Audio.play_spatial_sound(death_sound, global_position)
		hitbox.queue_free()
		hazard_area.queue_free()

func _on_anim_finished(anim : String) -> void:
	if anim == "stun":
		animation_player.play("walk")
	elif anim == "death":
		queue_free()
