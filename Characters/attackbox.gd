@icon("uid://d27n8ypbnck0q")
class_name Attackbox extends Area3D

@export var damage : float = 1.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_body_entered)
	monitorable = false
	monitoring = false
	

func _process(_delta: float) -> void:
	pass

func _on_body_entered(_n : Node3D) -> void:
	if _n is Hitbox:
		_n.take_damage(self)

func activate(duration : float = 0.1) -> void:
	monitoring = true
	await get_tree().create_timer(duration).timeout
	monitoring = false
