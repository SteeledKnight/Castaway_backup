class_name PlayerStateDeath extends PlayerState

const DEATH_AUDIO = preload("uid://ccaqwdfhetd80")


func enter() -> void:
	#TODO: Update to proper animation
	player.anim_player.play("dying_backward")
	Audio.play_spatial_sound(DEATH_AUDIO, player.global_position)
	Audio.play_music(null)
	await player.anim_player.animation_finished
	PlayerHud.show_game_over()

func exit() -> void:
	pass

func handle_input(_event: InputEvent) -> PlayerState:
	return null

func process(_delta: float) -> PlayerState:
	return null

func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = 0.0
	return null
