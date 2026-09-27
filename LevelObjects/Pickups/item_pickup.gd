@abstract
class_name ItemPickup extends CharacterBody3D

#var bounce_count : int = 8

@onready var area_3d: Area3D = $Area3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	area_3d.body_entered.connect(_on_body_entered)
	animation_player.play("rotate")
	

func _physics_process(_delta: float) -> void:
	#if bounce_count > 0:
		#velocity +=  get_gravity() * delta
		#var collision : KinematicCollision3D = move_and_collide(velocity * delta)
		#if collision:
			#bounce_count -= 1
			#velocity = velocity.bounce(collision.get_normal()) * 0.4
		pass

func _on_body_entered(p : Player) -> void:
	apply_effect(p)
	area_3d.body_entered.disconnect(_on_body_entered)
	#await animation if necessary
	queue_free()

func apply_effect(_p : Player) -> void:
	pass
