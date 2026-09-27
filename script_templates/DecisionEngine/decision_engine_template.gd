#class_name ___
extends DecisionEngine
#meta-name: DecisionEngine
#meta-default: true

#Included in DecisionEngine:
#var enemy : Enemy
#var current_state : EnemyState
#var blackboard : Blackboard

func _ready() -> void:
	await super() #Required for setup and timing
	#Add code below here

func decide() -> EnemyState:
	#Example decisions:
	#if blackboard.damage_sourceL
		#if blackboard.health <= 0.0:
			#return es_death
		#else:
			#return es_stun
	#if current_state is ESDeath or not blackboard.can_decide:
		#return null
	
	#if blackboard.target:
		#if blackboard.distance_to_target < 1:
			#return attack_state
		#else:
			#return chase_state
	return null
