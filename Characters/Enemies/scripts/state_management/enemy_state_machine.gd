@icon("uid://dvte1qaq6rjxv")
class_name EnemyStateMachine extends Node


var enemy : Enemy
var blackboard : Blackboard
var states : Array[EnemyState]
var current_state : EnemyState:
	get():
		return states.front()
var prev_state : EnemyState :
	get():
		return states.get(1)

func setup(e : Enemy, b : Blackboard) -> void:
	blackboard = b
	enemy = e
	for c in get_children():
		if c is EnemyState:
			c.enemy = enemy
			c.blackboard = blackboard
			c.state_machine = self
			states.append(c)
	current_state.enter()

func change_state(new_state : EnemyState) -> void:
	if not new_state:
		return
	if new_state == current_state:
		current_state.re_enter()
		return
	if current_state:
		current_state.exit()
	
	states.push_front(new_state)
	current_state.enter()
	if enemy:
		enemy.decision_engine.current_state = new_state
	states.resize(3)
	
func physics_update(_delta : float) -> void:
	if current_state:
		current_state.physics_update(_delta)
