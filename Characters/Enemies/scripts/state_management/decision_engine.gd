@icon("uid://b5btdfh3ku1l4")
class_name DecisionEngine extends Node

var enemy : Enemy
var current_state : EnemyState
var blackboard : Blackboard

func _ready() -> void:
	while not enemy:
		await get_tree().process_frame

func decide() -> EnemyState:
	return null
