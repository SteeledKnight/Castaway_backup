class_name PlayerStateFall extends PlayerState

var coyote_timer : float = 0.0
var jump_buffer_timer : float = 0.0

func init() -> void:
	pass


func enter() -> void:
	player.anim_player.play("falling")
	if player.previous_state == jump or player.previous_state == attack:
		coyote_timer = 0
	else:
		coyote_timer = player.COYOTE_TIME

func exit() -> void:
	jump_buffer_timer = 0.0


func handle_input(event: InputEvent) -> PlayerState:
	if event.is_action_pressed("attack"):
		return attack
	if event.is_action_pressed("jump"):
		if coyote_timer > 0.0:
			return jump
		else:
			jump_buffer_timer = player.COYOTE_TIME
		
	return next_state


func process(_delta: float) -> PlayerState:
	if coyote_timer > 0.0:
		coyote_timer -= _delta
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= _delta
	return next_state


func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = move_toward(player.velocity.x, (player.direction.x * player.SPEED), 0.1)
	if player.is_on_floor():
		if jump_buffer_timer > 0 and Input.is_action_pressed("jump"):
			return jump
		if player.velocity.x == 0:
			VfxManager.spawn_dust(player.feet.global_position)
			return idle
		else:
			VfxManager.spawn_dust(player.feet.global_position)
			return run
	return next_state
