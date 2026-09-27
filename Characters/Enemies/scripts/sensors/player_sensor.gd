@icon("uid://t0ntlctssg7d")
class_name PlayerSensor extends Area3D

signal player_found
@warning_ignore("unused_signal")
signal player_lost
signal started_searching

@export var search_duration : float = 2.0

var enemy : Enemy
var search_timer : float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_collision_mask_value(1, false)
	set_collision_layer_value(1, false)
	if owner is Enemy:
		enemy = owner
		set_collision_mask_value(5, true)
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)
	else: 
		push_warning("Player Sensor should be assigned to an enemy")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if search_timer > 0:
		search_timer -= delta
		if search_timer <= 0:
			player_lost.emit()
			enemy.blackboard.target = null

func _on_body_entered(p : Player) -> void:
	player_found.emit()
	search_timer = 0
	enemy.blackboard.target = p

func _on_body_exited(_p : Player) -> void:
	started_searching.emit()
	search_timer = search_duration
