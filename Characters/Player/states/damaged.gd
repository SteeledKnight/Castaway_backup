class_name PlayerStateDamaged extends PlayerState

@export var knockback : float
@export var invulnerable_duration : float = 1.0
var invulnerable : bool = false
var time : float = 0.0
var dir : float = 1.0
@onready var hitbox: Hitbox = %Hitbox
@onready var grunt_audio : AudioStream = preload("uid://b13i08wuskcfm")


func init() -> void:
	hitbox.damaged.connect(_on_damaged)
	knockback = player.SPEED / 2.0

func enter() -> void:
	#TODO: Change to proper animation
	player.anim_player.play("stunned")
	hitbox.start_invulnerable_time()
	Audio.play_spatial_sound(grunt_audio, player.global_position)
	invulnerable = true
	VfxManager.camera_shake()
	await player.anim_player.animation_finished
	invulnerable = false
	player.visible = true
	if player.hp <= 0.0:
		player.change_state(death)
	else:
		player.change_state(idle)

func exit() -> void:
	pass

func handle_input(_event: InputEvent) -> PlayerState:
	return null

func process(_delta: float) -> PlayerState:
	return null

func physics_process(_delta: float) -> PlayerState:
	if invulnerable:
		player.visible = !player.visible
	player.velocity.x = knockback * dir
	return null

func _on_damaged(attackbox : Attackbox) -> void:
	if player.current_state == death:
		return
	player.change_state(self)
	if attackbox.global_position.x < player.global_position.x:
		dir = 1.0
	else:
		dir = -1.0
