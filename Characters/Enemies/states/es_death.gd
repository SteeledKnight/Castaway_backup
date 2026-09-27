class_name ESDeath
extends EnemyState


#Included in EnemyState:
#@export var animation_name : String
#var state_machine : EnemyStateMachine
#var enemy : Enemy
#var blackboard : Blackboard
var invulnerable : bool = false
var time : float = 0.0
var dir : float = 1.0

func enter() -> void:
	invulnerable = true
	enemy.hitbox.queue_free()
	enemy.hazard_area.queue_free()
	if blackboard.damage_source.global_position.x < enemy.global_position.x:
		dir = 1.0
	else:
		dir = -1.0
	enemy.was_killed.emit(blackboard.damage_source)
	blackboard.damage_source = null
	blackboard.can_decide = false
	enemy.velocity.x = 0.0
	if enemy.death_sound:
		Audio.play_spatial_sound(enemy.death_sound, enemy.global_position)
	var anim : String = animation_name if animation_name else "death"
	enemy.play_animation(anim)
	await enemy.animation.animation_finished
	enemy.queue_free()
	
func re_enter() -> void:
	pass
	
func exit() -> void:
	pass
	
func physics_update(_delta : float) -> void:
	pass
