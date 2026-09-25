class_name PlayerStateAttack extends PlayerState

@export var audio : AudioStream
@export var attack_movement_damping : float = 1.5

var was_on_floor := true

func init() -> void:
	pass

func enter() -> void:
	next_state = null
	player.anim_player.animation_finished.connect(_on_anim_finished)
	do_attack()

func exit() -> void:
	player.anim_player.animation_finished.disconnect(_on_anim_finished)

func handle_input(_event: InputEvent) -> PlayerState:
	return null

func process(_delta: float) -> PlayerState:
	return next_state

func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = player.direction.x * (player.SPEED * attack_movement_damping)
	if player.is_on_floor() and !was_on_floor:
		VfxManager.spawn_dust(player.feet.global_position)
	if !player.is_on_floor():
		was_on_floor = false
	return null

func do_attack() -> void:
	VfxManager.camera_shake(.05)
	#HACK: need to fix for final models/animations
	player.anim_player.play("cross_punch", -1, 4.0)
	player.attackbox.activate()
	Audio.play_spatial_sound(audio, player.global_position)

func _end_attack() -> void:
	if player.is_on_floor():
		next_state = idle
	else: 
		next_state = fall

func _on_anim_finished(_anim_name : String) -> void:
	_end_attack()
