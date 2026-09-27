class_name HealthPickup extends ItemPickup

@export var heal_amount : float = 1.0

func apply_effect(p : Player) -> void:
	p.hp += heal_amount
