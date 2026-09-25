class_name PlayerStateRun extends PlayerState

#region // state references

#endregion

func init() -> void:
	pass


func enter() -> void:
	player.anim_player.play("run-slow")
	pass


func exit() -> void:
	pass


func handle_input(event: InputEvent) -> PlayerState:
	if event.is_action_pressed("attack"):
		return attack
	if event.is_action_pressed("jump"):
		return jump
	return next_state

func process(_delta: float) -> PlayerState:
	if player.direction.x == 0:
		return idle
	if player.direction.y > 0.5:
		return crouch
	return next_state


func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = move_toward(player.velocity.x, (player.direction.x * player.SPEED), 1.0)
	if !player.is_on_floor():
		return fall
	return next_state
