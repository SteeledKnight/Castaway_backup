class_name ESStun
extends EnemyState

#Included in EnemyState:
#@export var animation_name : String
#var state_machine : EnemyStateMachine
#var enemy : Enemy
#var blackboard : Blackboard

var knockback : float
var invulnerable : bool = false
var time : float = 0.0
var dir : float = 1.0
@onready var hitbox: Hitbox = %Hitbox

func start() -> void:
	invulnerable = true
	if blackboard.damage_source.global_position.x < enemy.global_position.x:
		dir = 1.0
	else:
		dir = -1.0
	blackboard.damage_source = null
	blackboard.can_decide = false
	knockback = enemy.move_speed / 2.0
	var anim : String = animation_name if animation_name else "stun"
	if enemy.animation.current_animation == anim:
		enemy.animation.seek(0)
	else:
		enemy.play_animation(anim)
	hitbox.start_invulnerable_time()
	await enemy.animation.animation_finished
	invulnerable = false
	enemy.visible = true
	blackboard.can_decide = true


func enter() -> void:
	start()
	
func re_enter() -> void:
	start()
	
func exit() -> void:
	pass
	
func physics_update(_delta : float) -> void:
	if invulnerable:
		enemy.visible = !enemy.visible
	enemy.velocity.x = knockback * dir
