class_name BasicDecisionEngine
extends DecisionEngine

#Included in DecisionEngine:
#var enemy : Enemy
#var current_state : EnemyState
#var blackboard : Blackboard

@onready var es_death: ESDeath = %ESDeath
@onready var es_stun: ESStun = %ESStun
@onready var es_walk: ESWalk = %ESWalk

func _ready() -> void:
	await super() #Required for setup and timing

func decide() -> EnemyState:
	if blackboard.damage_source:
		if blackboard.health <= 0.0:
			return es_death
		else:
			return es_stun
	if current_state is ESDeath:
		return null
	if not blackboard.can_decide:
		return null
	
	if blackboard.edge_detected:
		enemy.change_dir()
		
	return es_walk
