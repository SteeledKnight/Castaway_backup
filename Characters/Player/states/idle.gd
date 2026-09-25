class_name PlayerStateIdle extends PlayerState

#region // state references

#endregion

func init() -> void:
	pass


func enter() -> void:
	player.anim_player.play("idle")


func exit() -> void:
	pass


func handle_input(event: InputEvent) -> PlayerState:
	if event.is_action_pressed("attack"):
		return attack
	elif event.is_action_pressed("jump"):
		return jump
	return next_state


func process(_delta: float) -> PlayerState:
	if player.direction.x != 0:
		return run
	if player.direction.y > 0.5:
		return crouch
	return next_state


func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = move_toward(player.velocity.x, 0, 1)
	return next_state
