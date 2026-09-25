class_name PlayerStateCrouch extends PlayerState

#region // state references

#endregion

func init() -> void:
	pass


func enter() -> void:
	player.anim_player.play("stand_to_crouch")
	player.collision_standing.disabled = true
	player.collision_crouching.disabled = false
	player.hitbox_standing.disabled = true
	player.hitbox_crouching.disabled = false
	player.wants_drop = true
	pass


func exit() -> void:
	player.collision_standing.disabled = false
	player.collision_crouching.disabled = true
	player.hitbox_standing.disabled = false
	player.hitbox_crouching.disabled = true
	player.wants_drop = false
	pass


func handle_input(event: InputEvent) -> PlayerState:
	if event.is_action_pressed("attack"):
		return attack
	if event.is_action_pressed("jump"):
		return jump
	return next_state


func process(_delta: float) -> PlayerState:
	player.velocity.x = move_toward(player.velocity.x, (player.direction.x * player.SPEED / 2.0), 1.0)
	if player.direction.y < 0.5:
		return idle
	return next_state


func physics_process(_delta: float) -> PlayerState:
	return next_state
