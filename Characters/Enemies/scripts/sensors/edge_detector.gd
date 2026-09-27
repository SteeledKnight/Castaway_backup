@icon("uid://erxiip4ecvwu")
class_name EdgeDetector extends RayCast3D


signal edge_detected

var enemy : Enemy
var colliding : bool = true


func _ready() -> void:
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	if owner is Enemy:
		enemy = owner
	else: 
		push_warning("Edge Detector should be assigned to an enemy")

func _physics_process(_delta: float) -> void:
	if not enemy.is_on_floor():
		return
	var _is_colliding : bool = is_colliding()
	if colliding != _is_colliding:
		colliding = _is_colliding
		if not colliding:
			enemy.blackboard.edge_detected = true
			edge_detected.emit()
		else:
			enemy.blackboard.edge_detected = false
		
