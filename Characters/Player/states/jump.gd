class_name PlayerStateJump extends PlayerState

func init() -> void:
	pass

func enter() -> void:
	player.anim_player.play("jump")
	player.velocity.y = player.JUMP_VELOCITY

func exit() -> void:
	pass

func handle_input(event: InputEvent) -> PlayerState:
	if event.is_action_pressed("attack"):
		return attack
	if event.is_action_released("jump"):
		return fall
	return next_state

func process(_delta: float) -> PlayerState:
	return next_state

func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = move_toward(player.velocity.x, (player.direction.x * player.SPEED), 0.1)
	if player.is_on_floor():
		if player.velocity.x == 0:
			return idle
		else:
			return run
	if player.velocity.y < 0:
		return fall
	return next_state
